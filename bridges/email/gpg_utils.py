"""LA-Mesh GPG Utilities

Provides GPG signature verification and signing for the email bridge.
Used to authenticate messages flowing between email and mesh.

Requirements:
  pip install python-gnupg

GPG Keyring:
  The bridge maintains a local GPG keyring at /opt/lamesh/gpg/
  Import trusted operator keys before use.
"""

import logging
import os

try:
    import gnupg
except ImportError:
    gnupg = None

log = logging.getLogger("gpg_utils")

GPG_HOME = os.getenv("GPG_HOME", "/opt/lamesh/gpg")
GPG_KEYRING = os.getenv("GPG_KEYRING", "")


def get_gpg() -> "gnupg.GPG | None":
    """Get a GPG instance configured for the bridge keyring."""
    if gnupg is None:
        log.error("python-gnupg not installed. Run: pip install python-gnupg")
        return None

    os.makedirs(GPG_HOME, exist_ok=True)

    gpg = gnupg.GPG(gnupghome=GPG_HOME)
    gpg.encoding = "utf-8"
    return gpg


def verify_signature(signed_message: str) -> dict:
    """Verify a GPG-signed message.

    Returns dict with:
      valid: bool - signature is valid and from a trusted key
      fingerprint: str - signing key fingerprint (if valid)
      username: str - signing key UID (if valid)
      message: str - the original unsigned message body
      error: str - error message (if invalid)
    """
    gpg = get_gpg()
    if gpg is None:
        return {"valid": False, "error": "GPG not available", "message": signed_message}

    try:
        verified = gpg.verify(signed_message)
        if verified.valid:
            # Extract the cleartext message
            # For clearsigned messages, the text is between the header and signature
            lines = signed_message.split("\n")
            in_body = False
            body_lines = []
            for line in lines:
                if line.startswith("-----BEGIN PGP SIGNED MESSAGE-----"):
                    continue
                if line.startswith("Hash:"):
                    continue
                if line == "":
                    in_body = True
                    continue
                if line.startswith("-----BEGIN PGP SIGNATURE-----"):
                    break
                if in_body:
                    body_lines.append(line)

            return {
                "valid": True,
                "fingerprint": verified.fingerprint,
                "username": verified.username or "unknown",
                "message": "\n".join(body_lines),
                "error": None,
            }
        else:
            return {
                "valid": False,
                "fingerprint": verified.fingerprint,
                "username": None,
                "message": signed_message,
                "error": verified.status or "Invalid signature",
            }
    except Exception as e:
        log.exception("GPG verification failed")
        return {"valid": False, "error": str(e), "message": signed_message}


def sign_message(message: str, key_fingerprint: str = "") -> str | None:
    """Sign a message with the bridge's GPG key.

    Args:
        message: plaintext message to sign
        key_fingerprint: specific key to sign with (default: first available)

    Returns:
        Clearsigned message string, or None on failure
    """
    gpg = get_gpg()
    if gpg is None:
        return None

    try:
        kwargs = {"clearsign": True}
        if key_fingerprint:
            kwargs["keyid"] = key_fingerprint

        signed = gpg.sign(message, **kwargs)
        if signed.ok:
            return str(signed)
        else:
            log.error("GPG signing failed: %s", signed.status)
            return None
    except Exception:
        log.exception("GPG signing failed")
        return None


def import_key(key_data: str) -> dict:
    """Import a GPG public key into the bridge keyring.

    Args:
        key_data: ASCII-armored public key

    Returns:
        dict with: success, fingerprint, count
    """
    gpg = get_gpg()
    if gpg is None:
        return {"success": False, "error": "GPG not available"}

    try:
        result = gpg.import_keys(key_data)
        if result.count > 0:
            return {
                "success": True,
                "fingerprint": result.fingerprints[0] if result.fingerprints else None,
                "count": result.count,
            }
        else:
            return {"success": False, "error": "No keys imported"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def list_keys() -> list[dict]:
    """List all keys in the bridge keyring."""
    gpg = get_gpg()
    if gpg is None:
        return []

    keys = gpg.list_keys()
    return [
        {
            "fingerprint": k["fingerprint"],
            "uids": k["uids"],
            "expires": k.get("expires", ""),
            "trust": k.get("trust", ""),
        }
        for k in keys
    ]
