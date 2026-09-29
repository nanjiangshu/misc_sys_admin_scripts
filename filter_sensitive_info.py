#!/usr/bin/env python3
"""
Local Sensitive Data Redactor
Safely redacts sensitive keys, tokens, passwords, URLs, and PII locally.
Uses standard library modules only (no network connectivity).
"""

import sys
import re
from pathlib import Path

# Static replacement patterns (no capturing group dependencies)
PATTERNS = {
    # 1. Private Keys
    "PEM Private Key": r"-----BEGIN (?:RSA|OPENSSH|EC|PGP)? PRIVATE KEY-----[[\s\S]*?-----END (?:RSA|OPENSSH|EC|PGP)? PRIVATE KEY-----",

    # 2. Direct Access Links & Cloud Links
    "Google Docs/Drive": r"https?://(?:docs|drive)\.google\.com/[^\s'\"]+",
    "Dropbox Link": r"https?://(?:www\.)?dropbox\.com/[^\s'\"]+",
    "AWS S3 Direct Link": r"https?://[a-zA-Z0-9.\-]+\.s3[a-zA-Z0-9.\-]*\.amazonaws\.com/[^\s'\"]*",

    # 3. Known Token Formats
    "AWS Key ID": r"\b(AKIA|ASIA)[0-9A-Z]{16}\b",
    "GitHub Token": r"\bgh[pousr]_[A-Za-z0-9_]{36,255}\b",

    # 4. Personal Identification Numbers
    "Swedish Personal Number": r"\b(?:19|20)?\d{6}[-\+]?\d{4}\b",
    "US SSN": r"\b\d{3}-\d{2}-\d{4}\b",

    # 5. Contact Info
    "Email Address": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b",
    "Phone Number": r"\b(?:\+\d{1,3}[- ]?)?\(?\d{2,4}\)?[- ]?\d{3,4}[- ]?\d{3,4}\b",
}

# Key-Value patterns commonly found in config files (e.g., s3cmd, .env, json, yaml)
CONFIG_KEY_PATTERNS = [
    # Match keys like access_key, secret_key, password, token, user, api_key = <value>
    r"(?i)(\b(?:access_key|secret_key|secret|password|passwd|pwd|token|api_key|auth_token|user|username|name)\s*[:=]\s*)([^\s'\"\}]+)",
]


def redact_text(content: str) -> str:
    """Applies redaction rules safely."""
    redacted_content = content

    # 1. Redact Key-Value Secrets (e.g., s3cmd config parameters)
    for pattern in CONFIG_KEY_PATTERNS:
        redacted_content = re.sub(
            pattern,
            r"\1[REDACTED_VALUE]",
            redacted_content
        )

    # 2. Redact URLs with query string tokens or credentials
    redacted_content = re.sub(
        r"https?://[^\s'\"]+\?[^\s'\"]*",
        "[REDACTED_URL_WITH_PARAMS]",
        redacted_content
    )

    # 3. Apply general static replacements
    for label, pattern in PATTERNS.items():
        replacement = f"[REDACTED_{label.upper().replace(' ', '_').replace('/', '_')}]"
        try:
            redacted_content = re.sub(pattern, replacement, redacted_content)
        except re.error as e:
            print(f"Warning: Skipping pattern '{label}' due to regex error: {e}", file=sys.stderr)

    return redacted_content


def process_file(input_path: str, output_path: str = None) -> None:
    """Processes a local file safely."""
    in_file = Path(input_path)

    if not in_file.is_file():
        print(f"Error: File '{input_path}' not found.", file=sys.stderr)
        sys.exit(1)

    if output_path is None:
        output_path = in_file.parent / f"{in_file.stem}_redacted{in_file.suffix}"
    else:
        output_path = Path(output_path)

    print(f"Processing file locally: {in_file}")
    with open(in_file, "r", encoding="utf-8", errors="ignore") as f:
        raw_text = f.read()

    sanitized_text = redact_text(raw_text)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(sanitized_text)

    print(f"Sanitized file successfully saved to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python filter_sensitive_info.py <path_to_input_file> [path_to_output_file]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    process_file(input_file, output_file)
