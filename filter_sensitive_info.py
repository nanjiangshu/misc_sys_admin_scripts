#!/usr/bin/env python3

"""
Local Sensitive Data Redactor
=============================
A zero-dependency, 100% offline CLI tool and Python module designed to redact
sensitive information (passwords, passphrases, secret keys, tokens, PII such as
email, postal address, personal numbers, car plates, phone numbers, direct links) from files
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
    # 0. Passphrases & credentials embedded in URLs (run first)
    # --------------------------------------------------------------------------
    {
        "name": "Passphrase / Seed Phrase / Passcode",
        # Passphrases often contain spaces, so unquoted values run to end of line.
        "pattern": (
            r"(\b(?:pass[ _-]?phrase|pass[ _-]?code|seed[ _-]?phrase|secret[ _-]?phrase|"
            r"recovery[ _-]?phrase|mnemonic|master[ _-]?password)\b[\"']?\s*(?:[:=]|\bis\b)\s*)"
            r"(?!\"?\[REDACTED_)(\"(?:[^\"\\]|\\.)*\"|'(?:[^'\\]|\\.)*'|[^\r\n]+)"
        ),
        "replacement": r"\1[REDACTED_PASSPHRASE]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Credentials in URL (scheme://user:pass@host)",
        "pattern": r"(\b[a-z][a-z0-9+.\-]*://)[^\s/:@'\"]+:[^\s/@'\"]+@",
        "replacement": r"\1[REDACTED_CREDENTIALS]@",
        "flags": re.IGNORECASE,
    },
    # --------------------------------------------------------------------------
    # 1. Config Key-Value Pairs
    # --------------------------------------------------------------------------
    {
        "name": "Config Key-Value Secrets",
        "pattern": r"(\b(?:access_key|secret_key|secret|password|passwd|pwd|token|api_key|auth_token|user|username)\s*[:=]\s*)(?!\"?\[REDACTED_)([^\s'\"\}]+)",
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
        "pattern": r"-----BEGIN (?:(?:RSA|OPENSSH|EC|DSA|ENCRYPTED|PGP) )?PRIVATE KEY(?: BLOCK)?-----[\s\S]*?-----END (?:(?:RSA|OPENSSH|EC|DSA|ENCRYPTED|PGP) )?PRIVATE KEY(?: BLOCK)?-----",
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
    {
        "name": "Authorization Header / Bearer Token",
        "pattern": r"(\bAuthorization\s*[:=]\s*(?:Bearer|Basic|Token)?\s*|\bBearer\s+)(?!\[REDACTED_)[A-Za-z0-9._~+/=\-]{8,}",
        "replacement": r"\1[REDACTED_TOKEN]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "JSON Web Token",
        "pattern": r"\beyJ[A-Za-z0-9_\-]{5,}\.[A-Za-z0-9_\-]{5,}\.[A-Za-z0-9_\-]*",
        "replacement": "[REDACTED_JWT]",
        "flags": 0,
    },
    {
        "name": "Slack Token",
        "pattern": r"\bxox[abprs]-[A-Za-z0-9\-]{10,}",
        "replacement": "[REDACTED_SLACK_TOKEN]",
        "flags": 0,
    },
    {
        "name": "SSH Public Key Material",
        "pattern": r"\b(ssh-(?:rsa|ed25519|dss)|ecdsa-sha2-nistp\d+)\s+[A-Za-z0-9+/=]{40,}",
        "replacement": r"\1 [REDACTED_SSH_KEY]",
        "flags": 0,
    },
    # --------------------------------------------------------------------------
    # 4. PII & Identification (specific formats first, generic phone last)
    # --------------------------------------------------------------------------
    {
        "name": "Credit Card Number",
        "pattern": r"\b(?:\d{4}[- ]?){3}\d{4}\b",
        "replacement": "[REDACTED_CREDIT_CARD]",
        "flags": 0,
    },
    {
        "name": "IBAN",
        "pattern": r"\b[A-Z]{2}\d{2}(?: ?[A-Z0-9]{4}){2,7}(?: ?[A-Z0-9]{1,3})?\b",
        "replacement": "[REDACTED_IBAN]",
        "flags": 0,
    },
    {
        "name": "Swedish Personal Number (Personnummer / Samordningsnummer)",
        # YYMMDD or YYYYMMDD, optional -/+, 4 digits. Day 61-91 = samordningsnummer.
        "pattern": (
            r"(?<![\d-])(?:(?:19|20)\d{2}|\d{2})(?:0[1-9]|1[0-2])"
            r"(?:0[1-9]|[12]\d|3[01]|6[1-9]|[78]\d|9[01])[-+]?\d{4}(?![\d-])"
        ),
        "replacement": "[REDACTED_SWEDISH_ID]",
        "flags": 0,
    },
    {
        "name": "US Social Security Number (SSN)",
        "pattern": r"\b\d{3}-\d{2}-\d{4}\b",
        "replacement": "[REDACTED_US_SSN]",
        "flags": 0,
    },
    {
        "name": "Car Plate (labelled)",
        "pattern": (
            r"(\b(?:licen[sc]e[ _-]?plate|number[ _-]?plate|plate[ _-]?(?:no|number|nr)|"
            r"reg(?:istration)?[ _.-]?(?:no|number|nr)|regnr|reg\.?nr|registreringsnummer|"
            r"bil(?:ens)? ?nummer|kenteken|kennzeichen|immatriculation)\b\.?\s*[:=]?\s*)"
            r"[A-Z0-9ÅÄÖÜ][A-Z0-9ÅÄÖÜ \-]{2,9}[A-Z0-9ÅÄÖÜ]\b"
        ),
        "replacement": r"\1[REDACTED_CAR_PLATE]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Swedish Car Plate (ABC123 / ABC12D)",
        # Letters I, Q, V, Å, Ä, Ö are not used in Swedish plates.
        "pattern": r"\b[A-HJ-PR-UW-Z]{3}[ -]?\d{2}[\dA-HJ-PR-UW-Z]\b",
        "replacement": "[REDACTED_CAR_PLATE]",
        "flags": 0,
    },
    {
        "name": "German Car Plate (B-AB 1234)",
        "pattern": r"\b[A-ZÄÖÜ]{1,3}-[A-Z]{1,2} ?\d{1,4}[EH]?\b",
        "replacement": "[REDACTED_CAR_PLATE]",
        "flags": 0,
    },
    # --------------------------------------------------------------------------
    # 5. Contact Information
    # --------------------------------------------------------------------------
    {
        "name": "Email Address",
        # Also catches obfuscated forms: name [at] example [dot] com
        "pattern": (
            r"\b[A-Za-z0-9._%+\-]+(?:@|\s?[\[\(]\s?at\s?[\]\)]\s?)"
            r"[A-Za-z0-9\-]+(?:(?:\.|\s?[\[\(]\s?dot\s?[\]\)]\s?)[A-Za-z0-9\-]+)*"
            r"(?:\.|\s?[\[\(]\s?dot\s?[\]\)]\s?)[A-Za-z]{2,}\b"
        ),
        "replacement": "[REDACTED_EMAIL]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Street Address (Swedish)",
        # e.g. "Storgatan 12B", "Kungsvägen 5, lgh 1201", "Torget 3"
        "pattern": (
            r"\b[A-ZÅÄÖ][\wåäöÅÄÖé\-]*(?:gatan|gatan|gata|vägen|väg|allén|allé|gränd|gränden|"
            r"stigen|backen|torget|platsen|plan|leden|stråket|kajen|bron|holmen)"
            r"\s+\d{1,4}\s?[A-Za-z]?\b(?:\s*,?\s*(?:lgh|lägenhet|apt)\.?\s*\d+)?"
        ),
        "replacement": "[REDACTED_ADDRESS]",
        "flags": 0,
    },
    {
        "name": "Street Address (English)",
        # e.g. "221B Baker Street", "10 Downing St.", "42 Elm Road"
        "pattern": (
            r"\b\d{1,5}[A-Za-z]?\s+(?:[A-Z][A-Za-z'\-]*\s+){1,3}"
            r"(?:Street|St|Road|Rd|Avenue|Ave|Lane|Ln|Drive|Dr|Boulevard|Blvd|Way|Court|Ct|"
            r"Close|Place|Pl|Square|Sq|Terrace|Crescent|Highway|Hwy)\b\.?"
        ),
        "replacement": "[REDACTED_ADDRESS]",
        "flags": 0,
    },
    {
        "name": "Postal Code + City",
        # Swedish "123 45 Stockholm", Dutch "1234 AB Amsterdam", UK postcode, US "CA 94105"
        "pattern": (
            r"\b(?:\d{3} ?\d{2}\s+[A-ZÅÄÖ][a-zåäöé]+(?:\s[A-ZÅÄÖ][a-zåäöé]+)?"
            r"|\d{4} ?[A-Z]{2}\s+[A-Z][a-z]+"
            r"|[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}"
            r"|[A-Z]{2} \d{5}(?:-\d{4})?)\b"
        ),
        "replacement": "[REDACTED_POSTAL_ADDRESS]",
        "flags": 0,
    },
    {
        "name": "Labelled Address",
        "pattern": (
            r"(\b(?:(?:home|postal|mailing|street|billing|shipping|visiting)[ _-]?)?"
            r"(?:address|adress|addr|postadress|gatuadress)\b[\"']?\s*[:=]\s*)"
            r"(?!\"?\[REDACTED_)(\"[^\"\r\n]*\"|'[^'\r\n]*'|[^\r\n]+)"
        ),
        "replacement": r"\1[REDACTED_ADDRESS]",
        "flags": re.IGNORECASE,
    },
    {
        "name": "Phone Number",
        "pattern": r"(?:(?<!\w)\+\d{1,3}[- ]?)?\b\(?\d{2,4}\)?[- ]?\d{3,4}[- ]?\d{3,4}\b",
        "replacement": "[REDACTED_PHONE]",
        "flags": 0,
    },
    # --------------------------------------------------------------------------
    # HCL / Terraform / JSON / Config Key-Value Secrets
    # --------------------------------------------------------------------------
    {
        "name": "Terraform / HCL Sensitive Key Redactor",
        # Matches keys like: dbPassword, db_password, mqPassword, token, accessKey,
        # secretKey, passphrase, secretName, iss, api_key, etc.
        "pattern": (
            r'(\b"?(?:'
            r'dbPassword|db_password|mqPassword|mq_password|password|passwd|pwd|'
            r'token|accessKey|access_key|secretKey|secret_key|secret|secretName|secret_name|'
            r'passphrase|iss|api_key|apikey|auth_token|bearer_token|id|result|rotatePubKeyData|bcrypt_hash'
            r')"?\s*[:=]\s*)'  # Capture key and separator (: or =)
            r'(?!"?\[REDACTED_)("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|[^\s,}\]#]+)'  # Capture value (quoted or unquoted)
        ),
        "replacement": r'\1"[REDACTED_VALUE]"',
        "flags": re.IGNORECASE,
    },

    # --------------------------------------------------------------------------
    # Terraform Environment / Map Block Assignments (e.g. TF_VAR_*, sensitive variables)
    # --------------------------------------------------------------------------
    {
        "name": "Terraform TF_VAR or Environment Variables",
        "pattern": r'(\b(?:TF_VAR_[A-Za-z0-9_]*password[A-Za-z0-9_]*|TF_VAR_[A-Za-z0-9_]*secret[A-Za-z0-9_]*|TF_VAR_[A-Za-z0-9_]*token[A-Za-z0-9_]*)\s*[:=]\s*)("[^"]+"|\'[^\']+\'|[^\s]+)',
        "replacement": r'\1"[REDACTED_VALUE]"',
        "flags": re.IGNORECASE,
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
