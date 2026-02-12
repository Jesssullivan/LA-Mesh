# LA-Mesh Bridge Services

Communication bridges that connect the LoRa mesh network to external services.

## Architecture

```
LA-Mesh Nodes ──(LoRa)──→ MeshAdv-Mini HAT ──(SPI/UART)──→ Raspberry Pi
                                                                │
                                                          ┌─────┴─────┐
                                                          │meshtasticd│
                                                          └─────┬─────┘
                                                                │ MQTT
                                                          ┌─────┴─────┐
                                                    ┌─────┴──┐  ┌──┴─────┐
                                                    │SMS     │  │Email   │
                                                    │Bridge  │  │Bridge  │
                                                    └────┬───┘  └───┬────┘
                                                         │          │
                                                    Twilio API   SMTP
```

## Bridges

### SMS Bridge (`sms/`)
- Relays mesh messages to SMS via Twilio
- Mesh users send: `SMS:+12075551234 Your message here`
- Requires Twilio account with phone number

### Email Bridge (`email/`)
- Relays mesh messages to email via SMTP
- Mesh users send: `EMAIL:user@example.com Your message here`
- Supports any SMTP provider (SendGrid, Gmail SMTP, self-hosted)

### MQTT Configuration (`mqtt/`)
- MQTT broker config for bridge interconnection
- Meshtasticd publishes JSON messages to MQTT topics
- Bridges subscribe and relay to external services

## Deployment

### Prerequisites
- Raspberry Pi 4 with MeshAdv-Mini HAT
- Raspbian OS with meshtasticd installed
- Mosquitto MQTT broker (`sudo apt install mosquitto`)
- Python 3.10+

### Quick Start

```bash
# 1. Install dependencies
pip install paho-mqtt twilio python-dotenv

# 2. Configure bridges
cp bridges/sms/bridge.env.template /opt/lamesh/bridges/sms/.env
cp bridges/email/bridge.env.template /opt/lamesh/bridges/email/.env
# Edit .env files with your credentials

# 3. Install systemd services
sudo cp bridges/systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable lamesh-sms-bridge lamesh-email-bridge
sudo systemctl start lamesh-sms-bridge lamesh-email-bridge

# 4. Check status
sudo systemctl status lamesh-sms-bridge
sudo journalctl -u lamesh-sms-bridge -f
```

### Log Location
- SMS bridge: `/var/log/lamesh/sms-bridge.log`
- Email bridge: `/var/log/lamesh/email-bridge.log`
- meshtasticd: `journalctl -u meshtasticd`
- MQTT: `journalctl -u mosquitto`
