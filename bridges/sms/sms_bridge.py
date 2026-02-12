#!/usr/bin/env python3
"""LA-Mesh SMS Bridge

PROJECT: Not production-ready. SMS provider integration pending.
Currently monitors MQTT for SMS-prefixed messages. Outbound SMS delivery
requires an SMS gateway provider (TBD -- evaluating gammu-smsd, Android
SMS gateway, and hosted API providers).

Architecture:
  meshtasticd → MQTT → this script → SMS gateway API → SMS
  SMS → gateway webhook → this script → MQTT → meshtasticd → mesh

Usage:
  cp .env.template .env  # Fill in SMS gateway credentials
  python3 sms_bridge.py

Requires:
  pip install paho-mqtt python-dotenv
"""

import json
import logging
import os
import re
import sys
from datetime import datetime, timezone

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip install paho-mqtt")
    sys.exit(1)

try:
    from dotenv import load_dotenv
except ImportError:
    print("WARNING: python-dotenv not installed, using environment variables only")
    load_dotenv = None

# Load environment
if load_dotenv:
    load_dotenv()

# Configuration from environment
MQTT_HOST = os.getenv("MQTT_HOST", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC_INCOMING = os.getenv("MQTT_TOPIC_INCOMING", "msh/US/2/json/LongFast/+")
MQTT_TOPIC_OUTGOING = os.getenv("MQTT_TOPIC_OUTGOING", "msh/US/2/json/LongFast/!gateway")

SMS_GATEWAY_API_URL = os.getenv("SMS_GATEWAY_API_URL", "")
SMS_GATEWAY_API_KEY = os.getenv("SMS_GATEWAY_API_KEY", "")
SMS_GATEWAY_PHONE_NUMBER = os.getenv("SMS_GATEWAY_PHONE_NUMBER", "")

# Phone number allowlist (only these numbers can send TO the mesh)
ALLOWED_NUMBERS = os.getenv("ALLOWED_NUMBERS", "").split(",")

# SMS trigger prefix: messages starting with "SMS:" followed by a phone number
# Example mesh message: "SMS:+12075551234 Hello from the mesh!"
SMS_PREFIX = "SMS:"

# Logging
logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO")),
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("/var/log/lamesh/sms-bridge.log", mode="a"),
    ],
)
log = logging.getLogger("sms_bridge")


def validate_phone_number(number: str) -> str | None:
    """Validate and normalize a phone number to E.164 format."""
    cleaned = re.sub(r"[^\d+]", "", number)
    if re.match(r"^\+1\d{10}$", cleaned):
        return cleaned
    if re.match(r"^1\d{10}$", cleaned):
        return f"+{cleaned}"
    if re.match(r"^\d{10}$", cleaned):
        return f"+1{cleaned}"
    return None


def send_sms(to_number: str, message: str) -> bool:
    """Send an SMS via the configured gateway."""
    if not all([SMS_GATEWAY_API_URL, SMS_GATEWAY_API_KEY, SMS_GATEWAY_PHONE_NUMBER]):
        log.error("SMS gateway not configured")
        return False

    normalized = validate_phone_number(to_number)
    if not normalized:
        log.warning("Invalid phone number: %s", to_number)
        return False

    # TODO: Implement SMS gateway API call when provider is selected
    log.warning("SMS send not implemented -- gateway provider TBD. Would send to %s", normalized)
    return False


def on_mqtt_connect(client, userdata, flags, rc, properties=None):
    """Handle MQTT connection."""
    if rc == 0:
        log.info("Connected to MQTT broker at %s:%d", MQTT_HOST, MQTT_PORT)
        client.subscribe(MQTT_TOPIC_INCOMING)
        log.info("Subscribed to %s", MQTT_TOPIC_INCOMING)
    else:
        log.error("MQTT connection failed with code %d", rc)


def on_mqtt_message(client, userdata, msg):
    """Handle incoming MQTT messages from the mesh."""
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        log.debug("Non-JSON MQTT message on %s", msg.topic)
        return

    msg_type = payload.get("type", "")
    if msg_type != "text":
        return

    text = payload.get("payload", {}).get("text", "")
    sender = payload.get("sender", "unknown")
    timestamp = datetime.fromtimestamp(
        payload.get("timestamp", 0), tz=timezone.utc
    ).isoformat()

    log.info("Mesh message from %s: %s", sender, text[:100])

    # Check for SMS trigger prefix
    if not text.upper().startswith(SMS_PREFIX):
        return

    # Parse: SMS:+12075551234 message body
    parts = text[len(SMS_PREFIX) :].strip().split(" ", 1)
    if len(parts) < 2:
        log.warning("Malformed SMS command from %s: %s", sender, text)
        return

    phone_number, sms_body = parts
    full_message = f"[LA-Mesh {sender} {timestamp}] {sms_body}"

    log.info("SMS relay: %s → %s: %s", sender, phone_number, sms_body[:50])
    send_sms(phone_number, full_message)


def main():
    """Main entry point."""
    log.info("LA-Mesh SMS Bridge starting")
    log.info("MQTT: %s:%d", MQTT_HOST, MQTT_PORT)
    log.info(
        "SMS gateway: %s",
        "configured" if SMS_GATEWAY_API_URL else "NOT CONFIGURED",
    )

    if not SMS_GATEWAY_API_URL:
        log.warning(
            "SMS gateway not configured. Running in monitor-only mode. "
            "Set SMS_GATEWAY_API_URL, SMS_GATEWAY_API_KEY, SMS_GATEWAY_PHONE_NUMBER."
        )

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_mqtt_connect
    client.on_message = on_mqtt_message

    try:
        client.connect(MQTT_HOST, MQTT_PORT, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        log.info("SMS Bridge shutting down")
    except ConnectionRefusedError:
        log.error(
            "Cannot connect to MQTT broker at %s:%d. Is Mosquitto running?",
            MQTT_HOST,
            MQTT_PORT,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
