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
          "Output Bitwarden JSON file path.\n(default:"
          f" {default_output} - uses RAM disk when available)"
      ),
  )
  parser.add_argument(
      "-f",
      "--folder",
      default="Imported PGP",
      help=(
          "Target folder name inside Bitwarden.\n(default: 'Imported PGP')"
      ),
  )
  parser.add_argument(
      "--ext",
      default=".gpg",
      help="File extension to scan for (default: .gpg).",
  )
  parser.add_argument(
      "-l",
      "--limit",
      type=int,
      default=0,
      help="Only process the first N files (useful for testing).",
  )
  parser.add_argument(
      "--dry-run",
      action="store_true",
      help=(
          "Decrypt and parse files in memory without writing any output file."
      ),
  )
  parser.add_argument(
      "-v",
      "--verbose",
      action="store_true",
      help="Print parsed field summary for each file (masks passwords).",
  )

  args = parser.parse_args()

  input_dir = os.path.expanduser(args.input_dir)
  if not os.path.isdir(input_dir):
    print(f"Error: Input directory does not exist: {input_dir}", file=sys.stderr)
    sys.exit(1)

  ext = args.ext if args.ext.startswith(".") else f".{args.ext}"
  files = sorted(
      glob.glob(os.path.join(input_dir, "**", f"*{ext}"), recursive=True)
  )

  if not files:
    print(f"No '{ext}' files found in {input_dir}", file=sys.stderr)
    sys.exit(1)

  if args.limit > 0:
    files = files[: args.limit]

  folder_id = str(uuid.uuid4())
  vault_data = {
      "encrypted": False,
      "folders": [{"id": folder_id, "name": args.folder}],
      "items": [],
  }

  success = 0
  missing_pass_files = []

  print(f"Scanning {len(files)} '{ext}' files in {input_dir}...")

  for filepath in files:
    base = os.path.basename(filepath)
    name = os.path.splitext(base)[0]

    res = subprocess.run(
        ["gpg", "--quiet", "--batch", "--decrypt", filepath],
        capture_output=True,
        text=True,
    )
    if res.returncode != 0:
      print(f"[DECRYPT ERROR] {base}: {res.stderr.strip()}", file=sys.stderr)
      continue

    username, password, uri, notes, custom_fields = parse_free_text(
        name, res.stdout
    )

    if not password:
      missing_pass_files.append(base)

    if args.verbose:
      masked_pw = ("*" * len(password)) if password else "<NONE>"
      print(
          f"  [OK] {name} | user: {username or '<NONE>'} | pass: {masked_pw}"
          f" | uri: {uri or '<NONE>'}"
      )

    item = {
        "id": str(uuid.uuid4()),
        "folderId": folder_id,
        "type": 1,  # 1 = Login item
        "name": name,
        "notes": notes or None,
        "fields": custom_fields,
        "login": {
            "uris": [{"match": None, "uri": uri}] if uri else [],
            "username": username or None,
            "password": password or None,
            "totp": None,
        },
    }
    vault_data["items"].append(item)
    success += 1

  if args.dry_run:
    print(
        f"\n[DRY RUN] Parsed {success}/{len(files)} entries cleanly. No file"
        " written."
    )
  else:
    output_path = os.path.expanduser(args.output)
    with open(output_path, "w", encoding="utf-8") as f:
      json.dump(vault_data, f, indent=2, ensure_ascii=False)
    # Restrict file permissions to owner read/write only (600)
    os.chmod(output_path, 0o600)
    print(f"\nDone! Exported {success}/{len(files)} entries to: {output_path}")
    print(
        f"Remember to delete '{output_path}' immediately after importing into"
        " Bitwarden."
    )

  if missing_pass_files:
    print(
        f"\nNote: {len(missing_pass_files)} files had no active 'passwd:' or"
        " 'password:' tag (full text was still saved in Bitwarden Notes):"
    )
    for f_name in missing_pass_files[:20]:
      print(f"  - {f_name}")
    if len(missing_pass_files) > 20:
      print(f"  ... and {len(missing_pass_files) - 20} more.")


if __name__ == "__main__":
  main()
