#!/usr/bin/env python3
"""LA-Mesh Email Bridge

Bridges Meshtastic mesh messages to/from email via SMTP.
Runs on the Raspberry Pi gateway alongside meshtasticd.

Architecture:
  meshtasticd → MQTT → this script → SMTP → Email
  Email → IMAP poll → this script → MQTT → meshtasticd → mesh

Usage:
  cp .env.template .env  # Fill in SMTP credentials
  python3 email_bridge.py

Requires:
  pip install paho-mqtt python-dotenv
"""

import json
import logging
import os
import re
import smtplib
import sys
from datetime import datetime, timezone
from email.message import EmailMessage

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

# MQTT Configuration
MQTT_HOST = os.getenv("MQTT_HOST", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC_INCOMING = os.getenv("MQTT_TOPIC_INCOMING", "msh/US/2/json/LongFast/+")

# SMTP Configuration
SMTP_HOST = os.getenv("SMTP_HOST", "")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USERNAME = os.getenv("SMTP_USERNAME", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM_ADDRESS = os.getenv("SMTP_FROM_ADDRESS", "")
SMTP_USE_TLS = os.getenv("SMTP_USE_TLS", "true").lower() == "true"

# Email trigger prefix: messages starting with "EMAIL:" followed by an address
# Example mesh message: "EMAIL:user@example.com Subject: Hello from mesh!"
EMAIL_PREFIX = "EMAIL:"

# Allowed recipient domains (empty = all allowed)
ALLOWED_DOMAINS = [d.strip() for d in os.getenv("ALLOWED_DOMAINS", "").split(",") if d.strip()]

# Logging
logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO")),
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("/var/log/lamesh/email-bridge.log", mode="a"),
    ],
)
log = logging.getLogger("email_bridge")

# Simple email regex for validation
EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")


def validate_email(address: str) -> bool:
    """Validate an email address format and domain."""
    if not EMAIL_REGEX.match(address):
        return False

    if ALLOWED_DOMAINS:
        domain = address.split("@")[1].lower()
        if domain not in [d.lower() for d in ALLOWED_DOMAINS]:
            log.warning("Email domain %s not in allowlist", domain)
            return False

    return True


def send_email(to_address: str, subject: str, body: str) -> bool:
    """Send an email via SMTP."""
    if not all([SMTP_HOST, SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM_ADDRESS]):
        log.error("SMTP credentials not configured")
        return False

    if not validate_email(to_address):
        log.warning("Invalid or disallowed email: %s", to_address)
        return False

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = SMTP_FROM_ADDRESS
    msg["To"] = to_address
    msg.set_content(body)

    try:
        if SMTP_USE_TLS:
            with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
                server.starttls()
                server.login(SMTP_USERNAME, SMTP_PASSWORD)
                server.send_message(msg)
        else:
            with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
                server.login(SMTP_USERNAME, SMTP_PASSWORD)
                server.send_message(msg)

        log.info("Email sent to %s: %s", to_address, subject[:50])
        return True
    except Exception:
        log.exception("Failed to send email to %s", to_address)
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

    # Check for EMAIL trigger prefix
    if not text.upper().startswith(EMAIL_PREFIX):
        return

    # Parse: EMAIL:user@example.com Message body here
    remainder = text[len(EMAIL_PREFIX) :].strip()
    parts = remainder.split(" ", 1)
    if len(parts) < 2:
        log.warning("Malformed EMAIL command from %s: %s", sender, text)
        return

    email_address = parts[0]
    email_body = parts[1]

    subject = f"LA-Mesh message from {sender}"
    full_body = (
        f"Message from LA-Mesh node {sender}\n"
        f"Received: {timestamp}\n"
        f"---\n\n"
        f"{email_body}\n"
        f"\n---\n"
        f"Sent via LA-Mesh (LoRa mesh network)\n"
        f"This message was relayed from an off-grid mesh radio."
    )

    log.info("Email relay: %s → %s", sender, email_address)
    send_email(email_address, subject, full_body)


def main():
    """Main entry point."""
    log.info("LA-Mesh Email Bridge starting")
    log.info("MQTT: %s:%d", MQTT_HOST, MQTT_PORT)
    log.info(
        "SMTP: %s",
        f"{SMTP_HOST}:{SMTP_PORT}" if SMTP_HOST else "NOT CONFIGURED",
    )

    if not SMTP_HOST:
        log.warning(
            "SMTP not configured. Running in monitor-only mode. "
            "Set SMTP_HOST, SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM_ADDRESS."
        )

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_mqtt_connect
    client.on_message = on_mqtt_message

    try:
        client.connect(MQTT_HOST, MQTT_PORT, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        log.info("Email Bridge shutting down")
    except ConnectionRefusedError:
        log.error(
            "Cannot connect to MQTT broker at %s:%d. Is Mosquitto running?",
            MQTT_HOST,
            MQTT_PORT,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
