# SMS Bridge Design

**Status**: Implemented (scaffold)
**Code**: `bridges/sms/sms_bridge.py`

---

## Architecture

```
Phone ──(SMS)──→ Twilio ──(MQTT)──→ Bridge ──(MQTT)──→ meshtasticd ──(LoRa)──→ Mesh
Mesh ──(LoRa)──→ meshtasticd ──(MQTT)──→ Bridge ──(Twilio API)──→ Phone
```

## Message Flow: Mesh → SMS

1. Mesh user sends: `SMS:+12075551234 Hello from the mesh!`
2. meshtasticd publishes to MQTT: `msh/US/2/json/LongFast/+`
3. SMS bridge subscribes, detects `SMS:` prefix
4. Bridge parses phone number and message body
5. Bridge validates phone number (E.164 format)
6. Bridge sends SMS via Twilio API
7. Recipient receives: `[LA-Mesh !aabbccdd 2026-02-11T15:30:00Z] Hello from the mesh!`

## Message Flow: SMS → Mesh (Future)

1. Phone user sends SMS to Twilio number
2. Twilio forwards to webhook endpoint on Pi
3. Bridge publishes to MQTT outgoing topic
4. meshtasticd receives and broadcasts on mesh

**Note**: Inbound SMS requires the Pi to be internet-accessible (webhook). Options:
- Twilio webhook with ngrok or Cloudflare tunnel
- Twilio polling via API (no webhook needed, higher latency)

## Security

- Phone number allowlist prevents abuse
- Rate limiting prevents mesh flooding
- Message length truncated to LoRa payload limits (~200 bytes)
- No credentials stored in code (environment variables only)
