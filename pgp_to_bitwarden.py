#!/usr/bin/env python3
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import uuid

# Regex patterns tailored to your format (case-insensitive)
# Matches: username, user name, username1, user name 2, etc. (with : or =)
USER_RE = re.compile(
    r"\b(?:user\s*name\d*|username\d*)\s*[:=]\s*([^\s,;]+)", re.IGNORECASE
)

# Matches: passwd:, password:, passwd1:, password1: (with : or =)
PASS_RE = re.compile(
    r"\b(?:passw(?:or)?d\d*)\s*[:=]\s*(\S+)", re.IGNORECASE
)

# Matches URLs anywhere in the text
URL_RE = re.compile(r"(https?://[^\s]+|www\.[^\s]+)", re.IGNORECASE)


def parse_free_text(filename, raw_text):
  """Parses free-text GPG password files while preserving dates and # obsolete lines in notes."""
  lines = raw_text.splitlines()

  found_users = []
  found_passwords = []
  uri = ""
  note_lines = []

  for raw_line in lines:
    stripped = raw_line.strip()
    if not stripped:
      continue

    # Always keep every original line in notes so dates, comments, and # obsolete history are preserved
    note_lines.append(stripped)

    # Skip obsolete lines starting with '#' when extracting active credentials
    if stripped.startswith("#"):
      continue

    # Extract URL if not found yet
    if not uri:
      url_match = URL_RE.search(stripped)
      if url_match:
        u = url_match.group(1)
        uri = u if u.lower().startswith("http") else f"https://{u}"

    # Extract username(s) on this line (works even if password is on the same line)
    for u_match in USER_RE.finditer(stripped):
      val = u_match.group(1).strip()
      if not re.match(r"^(?:passw(?:or)?d\d*|user\s*name\d*)\s*[:=]", val, re.I):
        found_users.append(val)

    # Extract active password(s) on this line
    for p_match in PASS_RE.finditer(stripped):
      val = p_match.group(1).strip()
      if not re.match(r"^(?:passw(?:or)?d\d*|user\s*name\d*)\s*[:=]", val, re.I):
        found_passwords.append(val)

  primary_user = found_users[0] if found_users else ""
  primary_pass = found_passwords[0] if found_passwords else ""

  # Secondary logins (e.g., username1 + password1) go into Bitwarden Custom Fields
  custom_fields = []
  extra_count = max(len(found_users), len(found_passwords))
  for idx in range(1, extra_count):
    if idx < len(found_users):
      custom_fields.append({
          "name": f"username_{idx + 1}",
          "value": found_users[idx],
          "type": 0,  # 0 = Text
      })
    if idx < len(found_passwords):
      custom_fields.append({
          "name": f"password_{idx + 1}",
          "value": found_passwords[idx],
          "type": 1,  # 1 = Hidden (masked in Bitwarden UI)
      })

  # Fallback: if filename looks like a domain (e.g., github.com.gpg) and no URL was inside
  if not uri and "." in filename and " " not in filename:
    uri = f"https://{filename}"

  return primary_user, primary_pass, uri, "\n".join(note_lines), custom_fields


def main():
  default_out_dir = "/dev/shm" if os.path.isdir("/dev/shm") else "/tmp"
  default_output = os.path.join(default_out_dir, "bitwarden_import.json")

  parser = argparse.ArgumentParser(
      description=(
          "Convert a directory of GPG-encrypted free-text password files into a"
          " Bitwarden JSON import file."
      ),
      formatter_class=argparse.RawTextHelpFormatter,
  )
  parser.add_argument(
      "-i",
      "--input-dir",
      required=True,
      help="Directory containing your .gpg files (searched recursively).",
  )
  parser.add_argument(
      "-o",
      "--output",
      default=default_output,
      help=(
          "Output Bitwarden
