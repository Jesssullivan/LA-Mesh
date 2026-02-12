#!/usr/bin/env python3
"""LA-Mesh Node Status Monitor

Track which mesh nodes are online/offline based on MQTT heartbeats.
Prints a live status table and optionally alerts on node timeout.

Usage:
  python3 node-status.py [--broker localhost] [--timeout 3600]
"""

import argparse
import json
import sys
import time
from datetime import datetime, timezone

try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip install paho-mqtt")
    sys.exit(1)


class NodeTracker:
    def __init__(self, timeout_secs: int = 3600):
        self.nodes: dict[str, dict] = {}
        self.timeout_secs = timeout_secs

    def update(self, sender: str, payload: dict):
        now = time.time()
        msg_type = payload.get("type", "")

        if sender not in self.nodes:
            self.nodes[sender] = {
                "first_seen": now,
                "name": "unknown",
                "hw_model": "unknown",
                "battery": "?",
                "snr": "?",
            }

        node = self.nodes[sender]
        node["last_seen"] = now
        node["msg_count"] = node.get("msg_count", 0) + 1

        if msg_type == "nodeinfo":
            info = payload.get("payload", {})
            node["name"] = info.get("long_name", node["name"])
            node["hw_model"] = info.get("hw_model", node["hw_model"])
        elif msg_type == "telemetry":
            tel = payload.get("payload", {})
            if "battery_level" in tel:
                node["battery"] = f"{tel['battery_level']}%"
            if "voltage" in tel:
                node["voltage"] = f"{tel['voltage']}V"
        elif msg_type == "position":
            pos = payload.get("payload", {})
            lat = pos.get("latitude_i", 0) / 1e7
            lon = pos.get("longitude_i", 0) / 1e7
            node["position"] = f"{lat:.4f},{lon:.4f}"

    def get_status_table(self) -> str:
        now = time.time()
        lines = []
        lines.append(f"\033[2J\033[H")  # clear screen
        lines.append(f"LA-Mesh Node Status — {datetime.now().strftime('%H:%M:%S')}")
        lines.append(f"{'='*75}")
        lines.append(
            f"{'Node ID':<14} {'Name':<16} {'Status':<10} {'Last Seen':<12} "
            f"{'Battery':<10} {'Msgs':<6}"
        )
        lines.append(f"{'-'*75}")

        for node_id in sorted(self.nodes.keys()):
            node = self.nodes[node_id]
            last = node.get("last_seen", 0)
            age = now - last

            if age < 300:
                status = "\033[92mONLINE\033[0m "
            elif age < self.timeout_secs:
                status = "\033[93mIDLE\033[0m   "
            else:
                status = "\033[91mOFFLINE\033[0m"

            if age < 60:
                last_str = f"{int(age)}s ago"
            elif age < 3600:
                last_str = f"{int(age/60)}m ago"
            else:
                last_str = f"{int(age/3600)}h ago"

            lines.append(
                f"{node_id:<14} {node['name']:<16} {status:<20} {last_str:<12} "
                f"{node.get('battery', '?'):<10} {node.get('msg_count', 0):<6}"
            )

        lines.append(f"\n{len(self.nodes)} nodes tracked | "
                     f"Timeout: {self.timeout_secs}s | Ctrl+C to exit")
        return "\n".join(lines)


def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        client.subscribe("msh/#")


def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode("utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        return

    sender = payload.get("sender", "")
    if sender:
        userdata["tracker"].update(sender, payload)


def main():
    parser = argparse.ArgumentParser(description="LA-Mesh Node Status Monitor")
    parser.add_argument("--broker", default="localhost", help="MQTT broker host")
    parser.add_argument("--port", type=int, default=1883, help="MQTT broker port")
    parser.add_argument("--timeout", type=int, default=3600, help="Offline timeout (seconds)")
    parser.add_argument("--refresh", type=int, default=5, help="Display refresh interval (seconds)")
    args = parser.parse_args()

    tracker = NodeTracker(timeout_secs=args.timeout)
    userdata = {"tracker": tracker}

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, userdata=userdata)
    client.on_connect = on_connect
    client.on_message = on_message

    try:
        client.connect(args.broker, args.port, 60)
        client.loop_start()
        while True:
            print(tracker.get_status_table())
            time.sleep(args.refresh)
    except KeyboardInterrupt:
        print("\nStopped.")
        client.loop_stop()
    except ConnectionRefusedError:
        print(f"ERROR: Cannot connect to {args.broker}:{args.port}")
        sys.exit(1)


if __name__ == "__main__":
    main()
