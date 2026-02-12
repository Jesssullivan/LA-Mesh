#!/usr/bin/env python3
"""LA-Mesh MQTT to CSV Logger

Subscribe to mesh MQTT topics and log all messages to CSV files.
Creates separate CSVs for messages, positions, and telemetry.

Usage:
  python3 mqtt-to-csv.py [--broker localhost] [--output-dir ./logs]
"""

import argparse
import csv
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip install paho-mqtt")
    sys.exit(1)


class CSVLogger:
    def __init__(self, output_dir: str):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.writers = {}
        self.files = {}

    def _get_writer(self, name: str, fieldnames: list[str]):
        if name not in self.writers:
            date_str = datetime.now().strftime("%Y%m%d")
            filepath = self.output_dir / f"{name}-{date_str}.csv"
            is_new = not filepath.exists()
            f = open(filepath, "a", newline="")
            writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
            if is_new:
                writer.writeheader()
            self.writers[name] = writer
            self.files[name] = f
        return self.writers[name]

    def log_message(self, payload: dict):
        writer = self._get_writer("messages", [
            "timestamp", "sender", "channel", "text", "to", "msg_id",
        ])
        writer.writerow({
            "timestamp": datetime.fromtimestamp(
                payload.get("timestamp", 0), tz=timezone.utc
            ).isoformat(),
            "sender": payload.get("sender", ""),
            "channel": payload.get("channel", ""),
            "text": payload.get("payload", {}).get("text", ""),
            "to": payload.get("to", ""),
            "msg_id": payload.get("id", ""),
        })
        self.files["messages"].flush()

    def log_position(self, payload: dict):
        writer = self._get_writer("positions", [
            "timestamp", "sender", "latitude", "longitude", "altitude",
            "sats_in_view", "precision_bits",
        ])
        pos = payload.get("payload", {})
        writer.writerow({
            "timestamp": datetime.fromtimestamp(
                payload.get("timestamp", 0), tz=timezone.utc
            ).isoformat(),
            "sender": payload.get("sender", ""),
            "latitude": pos.get("latitude_i", 0) / 1e7,
            "longitude": pos.get("longitude_i", 0) / 1e7,
            "altitude": pos.get("altitude", 0),
            "sats_in_view": pos.get("sats_in_view", 0),
            "precision_bits": pos.get("precision_bits", 0),
        })
        self.files["positions"].flush()

    def log_telemetry(self, payload: dict):
        writer = self._get_writer("telemetry", [
            "timestamp", "sender", "battery_level", "voltage",
            "channel_utilization", "air_util_tx", "uptime_seconds",
        ])
        tel = payload.get("payload", {})
        writer.writerow({
            "timestamp": datetime.fromtimestamp(
                payload.get("timestamp", 0), tz=timezone.utc
            ).isoformat(),
            "sender": payload.get("sender", ""),
            "battery_level": tel.get("battery_level", ""),
            "voltage": tel.get("voltage", ""),
            "channel_utilization": tel.get("channel_utilization", ""),
            "air_util_tx": tel.get("air_util_tx", ""),
            "uptime_seconds": tel.get("uptime_seconds", ""),
        })
        self.files["telemetry"].flush()

    def close(self):
        for f in self.files.values():
            f.close()


def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print(f"Connected. Logging to {userdata['logger'].output_dir}/")
        client.subscribe("msh/#")
    else:
        print(f"Connection failed: rc={rc}")


def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        return

    logger = userdata["logger"]
    msg_type = payload.get("type", "")

    if msg_type == "text":
        logger.log_message(payload)
        sender = payload.get("sender", "?")
        text = payload.get("payload", {}).get("text", "")
        print(f"[MSG] {sender}: {text[:60]}")
    elif msg_type == "position":
        logger.log_position(payload)
    elif msg_type == "telemetry":
        logger.log_telemetry(payload)


def main():
    parser = argparse.ArgumentParser(description="LA-Mesh MQTT to CSV Logger")
    parser.add_argument("--broker", default="localhost", help="MQTT broker host")
    parser.add_argument("--port", type=int, default=1883, help="MQTT broker port")
    parser.add_argument("--output-dir", default="./logs", help="CSV output directory")
    args = parser.parse_args()

    logger = CSVLogger(args.output_dir)
    userdata = {"logger": logger}

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, userdata=userdata)
    client.on_connect = on_connect
    client.on_message = on_message

    print(f"LA-Mesh CSV Logger → {args.output_dir}/")
    try:
        client.connect(args.broker, args.port, 60)
        client.loop_forever()
    except KeyboardInterrupt:
        print("\nStopping logger.")
        logger.close()
    except ConnectionRefusedError:
        print(f"ERROR: Cannot connect to {args.broker}:{args.port}")
        sys.exit(1)


if __name__ == "__main__":
    main()
