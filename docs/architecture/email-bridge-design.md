# Email Bridge Design

**Status**: Implemented (scaffold)
**Code**: `bridges/email/email_bridge.py`, `bridges/email/gpg_utils.py`

---

## Architecture

```
Email ──(SMTP)──→ Bridge ──(MQTT)──→ meshtasticd ──(LoRa)──→ Mesh
Mesh ──(LoRa)──→ meshtasticd ──(MQTT)──→ Bridge ──(SMTP)──→ Email
```

## Message Flow: Mesh → Email

1. Mesh user sends: `EMAIL:user@example.com Hello from the mesh!`
2. meshtasticd publishes to MQTT
3. Email bridge detects `EMAIL:` prefix
4. Bridge validates email address and domain allowlist
5. Bridge composes email with mesh sender info and timestamp
6. Bridge sends via SMTP (optionally GPG-signed)
7. Recipient receives formatted email

## Message Flow: Email → Mesh (Future)

1. Email sent to bridge address (e.g., mesh@la-mesh.example.org)
2. Bridge polls IMAP inbox or receives webhook
3. Bridge verifies GPG signature (if present)
4. Bridge truncates message to LoRa payload limit
5. Bridge publishes to MQTT
6. meshtasticd broadcasts on mesh
7. Tag: `[VERIFIED: Operator Name]` or `[UNVERIFIED]`

## GPG Integration

- Bridge maintains a trusted keyring at `/opt/lamesh/gpg/`
- Incoming emails with valid GPG signatures get `[VERIFIED]` tag
- Outbound emails from mesh are signed with bridge's GPG key
- Unsigned emails are still relayed but marked `[UNVERIFIED]`

## Security

- Domain allowlist restricts recipients
- GPG verification authenticates senders
- Message truncation prevents oversized payloads
- SMTP credentials in environment variables only
- TLS for SMTP connections
