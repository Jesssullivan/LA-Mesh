# SMS Bridge Design

**Status**: Design document -- SMS gateway provider TBD
**Code**: `bridges/sms/sms_bridge.py`

---

## Architecture

```
Phone ──(SMS)──→ SMS Gateway ──(MQTT)──→ Bridge ──(MQTT)──→ meshtasticd ──(LoRa)──→ Mesh
Mesh ──(LoRa)──→ meshtasticd ──(MQTT)──→ Bridge ──(SMS Gateway API)──→ Phone
```

## Message Flow: Mesh → SMS

1. Mesh user sends: `SMS:+12075551234 Hello from the mesh!`
2. meshtasticd publishes to MQTT: `msh/US/2/json/LongFast/+`
3. SMS bridge subscribes, detects `SMS:` prefix
4. Bridge parses phone number and message body
5. Bridge validates phone number (E.164 format)
6. Bridge sends SMS via gateway API
7. Recipient receives: `[LA-Mesh !aabbccdd 2026-02-11T15:30:00Z] Hello from the mesh!`

## Message Flow: SMS → Mesh (Future)

1. Phone user sends SMS to gateway number
2. Gateway forwards to webhook endpoint on Pi
3. Bridge publishes to MQTT outgoing topic
4. meshtasticd receives and broadcasts on mesh

**Note**: Inbound SMS requires the Pi to be internet-accessible (webhook). Options:
- Gateway webhook with ngrok or Cloudflare tunnel
- Gateway polling via API (no webhook needed, higher latency)

## SMS Gateway Options Under Evaluation

| Option | Type | Pros | Cons |
|--------|------|------|------|
| gammu-smsd | Local GSM modem | No API dependency, works offline | Requires USB modem hardware |
| Android SMS Gateway | Phone-based relay | Low cost, uses existing phone plan | Depends on Android device |
| Hosted API (generic) | Cloud service | Reliable, scalable | Monthly cost, internet required |

## Security

- Phone number allowlist prevents abuse
- Rate limiting prevents mesh flooding
- Message length truncated to LoRa payload limits (~200 bytes)
- No credentials stored in code (environment variables only)
