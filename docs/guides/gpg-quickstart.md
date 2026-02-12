# GPG Quick Start for LA-Mesh

**Purpose**: Set up GPG for authenticated email bridge messages
**Audience**: Network operators and advanced users

---

## What GPG Does for LA-Mesh

The email bridge can verify GPG signatures on incoming emails, ensuring messages actually came from trusted senders. Outbound emails from the mesh can also be GPG-signed.

```
Operator → GPG-sign email → Email bridge verifies signature → "VERIFIED" tag on mesh
```

---

## Generate a Key Pair

```bash
# Generate a new key (follow prompts)
gpg --full-generate-key

# Recommended settings:
#   Type: RSA and RSA
#   Key size: 4096
#   Expiry: 1 year (renew annually)
#   Name: Your Name
#   Email: your.email@example.com
```

## Export Your Public Key

```bash
# ASCII-armored public key (share this)
gpg --armor --export your.email@example.com > my-key.pub

# Share with the bridge operator to import into the bridge keyring
```

## Import a Key (Bridge Operator)

```bash
# Import an operator's public key into the bridge keyring
GPG_HOME=/opt/lamesh/gpg gpg --import operator-key.pub

# Verify the import
GPG_HOME=/opt/lamesh/gpg gpg --list-keys
```

## Sign an Email

Most email clients support GPG signing:

- **Thunderbird**: Install the built-in OpenPGP support (Settings > Account > End-to-End Encryption)
- **TAILS**: Thunderbird in TAILS has GPG built-in
- **Command line**: `gpg --clearsign message.txt`

## Verify a Signature

```bash
# Verify a signed message
gpg --verify signed-message.txt
```

---

## Bridge Integration

The email bridge (`bridges/email/gpg_utils.py`) automatically:
1. Checks incoming emails for GPG signatures
2. Verifies against the bridge's trusted keyring
3. Tags verified messages with sender identity on the mesh
4. Signs outbound emails with the bridge's key

**Unverified emails** are still relayed but tagged as `[UNVERIFIED]` on the mesh.
