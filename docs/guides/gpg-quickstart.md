# GPG Quick Start for LA-Mesh

**Purpose**: Sign and encrypt messages, verify firmware and TAILS downloads, authenticate email bridge messages
**Audience**: All LA-Mesh participants

---

## What GPG Does for LA-Mesh

- **Email bridge authentication**: Verify signatures on incoming emails, sign outbound mesh-to-email
- **Message signing**: Prove authorship of a message to a specific recipient
- **Message encryption**: Encrypt arbitrary messages for specific people over insecure channels
- **File verification**: Verify downloaded firmware binaries and TAILS ISOs

---

## Generate a Key Pair (Ed25519)

Ed25519 keys are shorter, faster, and more secure than RSA-4096.

```bash
# Generate Ed25519 signing key with certification capability
gpg --quick-gen-key "Your Name <you@example.com>" ed25519 cert 0

# Add cv25519 encryption subkey
FINGERPRINT=$(gpg -k --with-colons you@example.com | grep fpr | head -1 | cut -d: -f10)
gpg --quick-add-key "$FINGERPRINT" cv25519 encr 0
```

Verify your key:

```bash
gpg -k --keyid-format long you@example.com
```

---

## Publish Your Public Key

### To a Keyserver

```bash
gpg --keyserver hkps://keys.openpgp.org --send-keys <KEY-ID>
```

Keyserver: [keys.openpgp.org](https://keys.openpgp.org)

### QR Code for In-Person Exchange

```bash
gpg --export <KEY-ID> | qrencode -o pubkey-qr.png
```

Scan at meetups for face-to-face key verification.

### ASCII Export

```bash
gpg --armor --export you@example.com > my-key.pub
```

---

## Sign and Encrypt Messages

```bash
# Clearsign a message (readable text + embedded signature)
gpg --clearsign message.txt

# Encrypt for a specific recipient (ASCII-armored)
gpg --encrypt --armor --recipient recipient@example.com message.txt

# Sign + encrypt
gpg --sign --encrypt --armor --recipient recipient@example.com message.txt
```

---

## Verify Signatures

```bash
# Verify a signed message
gpg --verify message.txt.asc

# Verify firmware release
gpg --verify firmware-2.7.15.zip.sig firmware-2.7.15.zip

# Verify TAILS ISO
gpg --verify tails-amd64-7.4.2.iso.sig tails-amd64-7.4.2.iso
```

---

## Client Setup

| Platform | Client | Notes |
|----------|--------|-------|
| Thunderbird | Built-in OpenPGP | Settings > Account > End-to-End Encryption. No Enigmail needed (Thunderbird 78+). |
| TAILS | Kleopatra (built-in) | GUI key manager included in TAILS desktop |
| Linux CLI | gpg | Installed by default on most distributions |
| macOS | GPG Suite | Integrates with Apple Mail |

---

## Bridge Integration

The email bridge (`bridges/email/gpg_utils.py`) automatically:

1. Checks incoming emails for GPG signatures
2. Verifies against the bridge's trusted keyring
3. Tags verified messages with sender identity on the mesh
4. Signs outbound emails with the bridge's key

**Unverified emails** are still relayed but tagged as `[UNVERIFIED]` on the mesh.

### Import a Key (Bridge Operator)

```bash
GPG_HOME=/opt/lamesh/gpg gpg --import operator-key.pub
GPG_HOME=/opt/lamesh/gpg gpg --list-keys
```
