#!/usr/bin/env python3

"""
Local Sensitive Data Redactor
=============================
A zero-dependency, 100% offline CLI tool and Python module designed to redact
sensitive information (passwords, secret keys, PII, direct links) from files
or standard input (pipes).

Usage:
------
1. Process file and output to STDOUT:
   $ python filter_sensitive_info.py config.conf

2. Process file and save to an output file:
   $ python filter_sensitive_info.py config.conf -o clean.conf

3. Use in a Linux pipeline (STDIN -> STDOUT):
   $ cat config.conf | python filter_sensitive_info.py > clean.conf
   $ grep "ERROR" app.log | python filter_sensitive_info.py
"""

import sys
import re
import argparse
from pathlib import Path
from typing import TypedDict


# Define explicit schema for rules
class RedactionRule(TypedDict, total=False):
    """
    Schema for a redaction rule.

    Attributes:
        name (str): A descriptive name for the rule.
        pattern (str): The regex pattern to match sensitive information.
        replacement (str): The string to replace the matched content with.
        flags (int): Regex flags (e.g., re.IGNORECASE).
    """
    name: str
    pattern: str
    replacement: str
    flags: int


# ==============================================================================
# EXTENSIBLE REDACTION RULES CONFIGURATION
# ==============================================================================
REDACTION_RULES: list[RedactionRule] = [
    # --------------------------------------------------------------------------
    # 1. Config Key-Value Pairs
    # --------------------------------------------------------------------------
    {
        "name": "Config Key-Value Secrets",
        "pattern": r"(\b(?:access_key|secret_key|secret|password|passwd|pwd|token|api_key|auth_token|user|username)\s*[:=]\s*)([^\s'\"\}]+)",
        "replacement": r"\1[REDACTED_VALUE]",
        "flags": re.IGNORECASE,
    },
    # --------------------------------------------------------------------------
    # 2. Cloud Storage URLs
    # --------------------------------------------------------------------------
    {
        "name": "Google Docs / Drive Links",
        "pattern": r"https?://(?:docs|drive)\.google\.com/[^\s'\"]+",
        "replacement": "[REDACTED_GOOGLE_DOCS_LINK]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Dropbox Links",
        "pattern": r"https?://(?:www\.)?dropbox\.com/[^\s'\"]+",
        "replacement": "[REDACTED_DROPBOX_LINK]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "AWS S3 Direct Bucket Links",
        "pattern": r"https?://[a-zA-Z0-9.\-]+\.s3[a-zA-Z0-9.\-]*\.amazonaws\.com/[^\s'\"]*",
        "replacement": "[REDACTED_S3_LINK]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "URLs with Query Parameters/Tokens",
        "pattern": r"https?://[^\s'\"]+\?[^\s'\"]*",
        "replacement": "[REDACTED_URL_WITH_PARAMS]",
        "flags": re.IGNORECASE,
    },
    # --------------------------------------------------------------------------
    # 3. Keys & Tokens
    # --------------------------------------------------------------------------
    {
        "name": "PEM Private Key Block",
        "pattern": r"-----BEGIN (?:RSA|OPENSSH|EC|PGP)? PRIVATE KEY-----[\s\S]*?-----END (?:RSA|OPENSSH|EC|PGP)? PRIVATE KEY-----",
        "replacement": "[REDACTED_PRIVATE_KEY]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "AWS Access Key ID",
        "pattern": r"\b(AKIA|ASIA)[0-9A-Z]{16}\b",
        "replacement": "[REDACTED_AWS_KEY_ID]",
        "flags": 0,
    },
    {
        "name": "GitHub Personal Access Token",
        "pattern": r"\bgh[pousr]_[A-Za-z0-9_]{36,255}\b",
        "replacement": "[REDACTED_GITHUB_TOKEN]",
        "flags": 0,
    },
    # --------------------------------------------------------------------------
    # 4. PII & Identification
    # --------------------------------------------------------------------------
    {
        "name": "Swedish Personal Number (Personnummer)",
        "pattern": r"\b(?:19|20)?\d{6}[-\+]?\d{4}\b",
        "replacement": "[REDACTED_SWEDISH_ID]",
        "flags": 0,
    },
    {
        "name": "US Social Security Number (SSN)",
        "pattern": r"\b\d{3}-\d{2}-\d{4}\b",
        "replacement": "[REDACTED_US_SSN]",
        "flags": 0,
    },
    # --------------------------------------------------------------------------
    # 5. Contact Information
    # --------------------------------------------------------------------------
    {
        "name": "Email Address",
        "pattern": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b",
        "replacement": "[REDACTED_EMAIL]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Phone Number",
        "pattern": r"\b(?:\+\d{1,3}[- ]?)?\(?\d{2,4}\)?[- ]?\d{3,4}[- ]?\d{3,4}\b",
        "replacement": "[REDACTED_PHONE]",
        "flags": 0,
    },
    {
        "name": "Credit Card Number",
        "pattern": r"\b(?:\d{4}[- ]?){3}\d{4}\b",
        "replacement": "[REDACTED_CREDIT_CARD]",
        "flags": 0,
    },
]


def redact_text(text: str, rules: list[RedactionRule] | None = None) -> str:
    """Applies redaction rules sequentially to input text."""
    if rules is None:
        rules = REDACTION_RULES

    sanitized_text = text
    for rule in rules:
        flags = rule.get("flags", re.IGNORECASE)
        try:
            sanitized_text = re.sub(rule.get("pattern", ""), rule.get("replacement", ""), sanitized_text, flags=flags)
        except re.error as err:
            sys.stderr.write(f"Warning: Skipping rule '{rule.get('name')}' due to regex error: {err}\n")

    return sanitized_text


def parse_arguments() -> argparse.Namespace:
    """Configures command-line options and positional arguments."""
    parser = argparse.ArgumentParser(
        description="Filter and redact sensitive information locally from text or streams.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  python filter_sensitive_info.py input.txt
  python filter_sensitive_info.py input.txt -o sanitized.txt
  cat input.txt | python filter_sensitive_info.py
""",
    )
    parser.add_argument(
        "input_file",
        nargs="?",
        type=str,
        default=None,
        help="Path to input file. If omitted, reads from standard input (STDIN).",
    )
    parser.add_argument(
        "-o",
        "--output",
        dest="output_file",
        type=str,
        default=None,
        help="Path to output file. If omitted, prints to standard output (STDOUT).",
    )
    return parser.parse_args()


def main() -> None:
    """Main entry point for the script."""
    args = parse_arguments()

    # 1. Read input data from File or STDIN pipe
    if args.input_file:
        in_path = Path(args.input_file)
        if not in_path.is_file():
            sys.stderr.write(f"Error: File '{args.input_file}' not found.\n")
            sys.exit(1)
        try:
            raw_data = in_path.read_text(encoding="utf-8", errors="ignore")
        except OSError as e:
            sys.stderr.write(f"Error reading file '{args.input_file}': {e}\n")
            sys.exit(1)
    else:
        if not sys.stdin.isatty():
            raw_data = sys.stdin.read()
        else:
            sys.stderr.write("Error: No input file provided and no STDIN pipe detected.\n")
            sys.stderr.write("Use --help for usage information.\n")
            sys.exit(1)

    # 2. Process & Redact
    sanitized_data = redact_text(raw_data)

    # 3. Output data to File or STDOUT
    if args.output_file:
        out_path = Path(args.output_file)
        try:
            out_path.write_text(sanitized_data, encoding="utf-8")
            sys.stderr.write(f"Successfully saved redacted content to: {out_path}\n")
        except OSError as e:
            sys.stderr.write(f"Error writing to output file '{args.output_file}': {e}\n")
            sys.exit(1)
    else:
        sys.stdout.write(sanitized_data)


if __name__ == "__main__":
    main()
