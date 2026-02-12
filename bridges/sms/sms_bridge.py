#!/usr/bin/env python3
"""LA-Mesh SMS Bridge

Bridges Meshtastic mesh messages to/from SMS via Twilio.
Runs on the Raspberry Pi gateway alongside meshtasticd.

Architecture:
  meshtasticd → MQTT → this script → Twilio API → SMS
  SMS → Twilio webhook → this script → MQTT → meshtasticd → mesh

Usage:
  cp .env.template .env  # Fill in Twilio credentials
  python3 sms_bridge.py

Requires:
  pip install paho-mqtt twilio python-dotenv
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
    from twilio.rest import Client as TwilioClient
except ImportError:
    print("ERROR: twilio not installed. Run: pip install twilio")
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

TWILIO_ACCOUNT_SID = os.getenv("TWILIO_ACCOUNT_SID", "")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN", "")
TWILIO_PHONE_NUMBER = os.getenv("TWILIO_PHONE_NUMBER", "")

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
    """Send an SMS via Twilio."""
    if not all([TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER]):
        log.error("Twilio credentials not configured")
        return False

    normalized = validate_phone_number(to_number)
    if not normalized:
        log.warning("Invalid phone number: %s", to_number)
        return False

    try:
        client = TwilioClient(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
        msg = client.messages.create(
            body=message,
            from_=TWILIO_PHONE_NUMBER,
            to=normalized,
        )
        log.info("SMS sent to %s (SID: %s)", normalized, msg.sid)
        return True
    except Exception:
        log.exception("Failed to send SMS to %s", normalized)
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
        "Twilio: %s",
        "configured" if TWILIO_ACCOUNT_SID else "NOT CONFIGURED",
    )

    if not TWILIO_ACCOUNT_SID:
        log.warning(
            "Twilio not configured. Running in monitor-only mode. "
            "Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER."
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
