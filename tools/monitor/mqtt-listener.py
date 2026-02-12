#!/usr/bin/env python3
"""LA-Mesh MQTT Listener

Subscribe to all mesh MQTT topics and print messages in real-time.
Useful for debugging and monitoring the mesh network.

Usage:
  python3 mqtt-listener.py [--broker localhost] [--port 1883] [--topic "msh/#"]
"""

import argparse
import json
import sys
from datetime import datetime, timezone

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip install paho-mqtt")
    sys.exit(1)


COLORS = {
    "text": "\033[92m",       # green
    "position": "\033[94m",   # blue
    "telemetry": "\033[93m",  # yellow
    "nodeinfo": "\033[96m",   # cyan
    "admin": "\033[91m",      # red
    "reset": "\033[0m",
}


def format_message(topic: str, payload: dict) -> str:
    """Format an MQTT message for display."""
    msg_type = payload.get("type", "unknown")
    sender = payload.get("sender", "?")
    ts = payload.get("timestamp", 0)
    time_str = datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%H:%M:%S") if ts else "??:??:??"

    color = COLORS.get(msg_type, "")
    reset = COLORS["reset"]

    if msg_type == "text":
        text = payload.get("payload", {}).get("text", "")
        return f"{color}[{time_str}] {sender} >> {text}{reset}"
    elif msg_type == "position":
        pos = payload.get("payload", {})
        lat = pos.get("latitude_i", 0) / 1e7
        lon = pos.get("longitude_i", 0) / 1e7
        alt = pos.get("altitude", 0)
        return f"{color}[{time_str}] {sender} @ {lat:.5f}, {lon:.5f} alt={alt}m{reset}"
    elif msg_type == "telemetry":
        tel = payload.get("payload", {})
        batt = tel.get("battery_level", "?")
        voltage = tel.get("voltage", "?")
        return f"{color}[{time_str}] {sender} batt={batt}% v={voltage}V{reset}"
    elif msg_type == "nodeinfo":
        info = payload.get("payload", {})
        name = info.get("long_name", "?")
        hw = info.get("hw_model", "?")
        return f"{color}[{time_str}] {sender} nodeinfo: {name} ({hw}){reset}"
    else:
        return f"[{time_str}] {sender} [{msg_type}] {json.dumps(payload.get('payload', {}))[:80]}"


def on_connect(client, userdata, flags, rc, properties=None):
    topic = userdata["topic"]
    if rc == 0:
        print(f"Connected to {userdata['broker']}:{userdata['port']}")
        print(f"Subscribed to: {topic}")
        print("-" * 60)
        client.subscribe(topic)
    else:
        print(f"Connection failed: rc={rc}")


def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
        print(format_message(msg.topic, payload))
    except (json.JSONDecodeError, UnicodeDecodeError):
        print(f"[RAW] {msg.topic}: {msg.payload[:100]}")


def main():
    parser = argparse.ArgumentParser(description="LA-Mesh MQTT Listener")
    parser.add_argument("--broker", default="localhost", help="MQTT broker host")
    parser.add_argument("--port", type=int, default=1883, help="MQTT broker port")
    parser.add_argument("--topic", default="msh/#", help="MQTT topic to subscribe")
    parser.add_argument("--no-color", action="store_true", help="Disable colored output")
    args = parser.parse_args()

    if args.no_color:
        for key in COLORS:
            COLORS[key] = ""

    userdata = {"broker": args.broker, "port": args.port, "topic": args.topic}
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, userdata=userdata)
    client.on_connect = on_connect
    client.on_message = on_message

    print(f"LA-Mesh MQTT Listener")
    print(f"Connecting to {args.broker}:{args.port}...")

    try:
        client.connect(args.broker, args.port, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        print("\nDisconnected.")
    except ConnectionRefusedError:
        print(f"ERROR: Cannot connect to {args.broker}:{args.port}")
        sys.exit(1)


if __name__ == "__main__":
    main()
