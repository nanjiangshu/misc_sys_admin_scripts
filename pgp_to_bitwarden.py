#!/usr/bin/env python3
"""Convert GPG-encrypted free-text credential files into a Bitwarden JSON import.

Typical use:
  # 1. check parsing without writing anything
  pgp_to_bitwarden.py -i ~/data3/private/key --dry-run -v
  # 2. write the import file (prefer a RAM disk / encrypted volume)
  pgp_to_bitwarden.py -i ~/data3/private/key -o /Volumes/RAMDisk/ -f "Imported PGP"
"""
import argparse
import json
import os
import re
import subprocess
import sys
import uuid

# Regex patterns tailored to your format (case-insensitive)
# Matches: username, user name, username1, user name 2, etc. (with : or =)
USER_RE = re.compile(
    r"\b(?:user\s*name\s*\d*|username\d*)\s*[:=]\s*([^\s,;]+)", re.IGNORECASE
)

# Fallback username when no explicit username tag exists
EMAIL_RE = re.compile(
    r"\be-?mail(?:\s*address)?\s*\d*\s*[:=]\s*([^\s,;]+@[^\s,;]+)", re.IGNORECASE
)

# Matches: passwd:, password:, passwd1:, newpasswd:, passcode:, and annotated
# forms like "new passwd (changed 2020-03-18):" or "passwd updated 2018-05-09:"
PASS_RE = re.compile(
    r"(?<![a-z])(?:new\s*)?(?:passw(?:or)?d|passcode)\s*\d*\s*"
    r"(?:\([^)]*\)|(?:updated|changed|reset|as\s+of)\s+[\d./-]+)?"
    r"\s*[:=]\s*(\S+)",
    re.IGNORECASE,
)

# A captured value that is itself another "key:" tag (e.g. "user: password: x")
TAG_VALUE_RE = re.compile(
    r"^(?:passw(?:or)?d\d*|user\s*name\d*)\s*[:=]?$", re.IGNORECASE
)

# Matches URLs anywhere in the text
URL_RE = re.compile(r"(https?://[^\s<>\"']+|www\.[^\s<>\"']+)", re.IGNORECASE)

# Looks like a hostname, e.g. github.com, mail.google.co.uk
DOMAIN_RE = re.compile(
    r"^(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z]{2,}$", re.IGNORECASE
)

# Suffixes in the decrypted file name that are not part of the entry name
NAME_SUFFIXES = (".key", ".txt", ".org", ".kep")

# Inner extensions that indicate a binary document, not a credential note
BINARY_SUFFIXES = (
    ".pdf", ".jpg", ".jpeg", ".png", ".gif", ".zip", ".gz", ".tar", ".doc",
    ".docx", ".xls", ".xlsx", ".rdata", ".p12", ".pfx",
)

# Bitwarden rejects encrypted values longer than 10000 chars. Encryption +
# base64 inflates plaintext by ~4/3 plus a header, so keep notes well below.
MAX_NOTES_BYTES = 7000


def entry_name(rel_path, exts):
  """'sub/github.com.key.gpg' -> 'sub/github.com'."""
  name = rel_path
  for ext in exts:
    if name.lower().endswith(ext):
      name = name[: -len(ext)]
      break
  for suffix in NAME_SUFFIXES:
    if name.lower().endswith(suffix):
      name = name[: -len(suffix)]
      break
  return name


def decode_text(data):
  """Return decoded text, or None if the payload looks binary."""
  if b"\x00" in data[:4096]:
    return None
  for enc in ("utf-8", "cp1252", "latin-1"):
    try:
      return data.decode(enc)
    except UnicodeDecodeError:
      continue
  return None


def parse_free_text(name, raw_text):
  """Parses free-text password files, keeping every line (incl. # obsolete) in notes."""
  found_users = []
  found_passwords = []
  found_emails = []
  uri = ""
  note_lines = []

  for raw_line in raw_text.splitlines():
    stripped = raw_line.strip()
    if not stripped:
      continue

    # Keep every original line so dates, comments and # obsolete history survive
    note_lines.append(stripped)

    # Skip obsolete lines starting with '#' when extracting active credentials
    if stripped.startswith("#"):
      continue

    if not uri:
      url_match = URL_RE.search(stripped)
      if url_match:
        u = url_match.group(1).rstrip(".,;:)]}>")
        uri = u if u.lower().startswith("http") else f"https://{u}"

    for u_match in USER_RE.finditer(stripped):
      val = u_match.group(1).strip()
      if val and not TAG_VALUE_RE.match(val):
        found_users.append(val)

    for p_match in PASS_RE.finditer(stripped):
      val = p_match.group(1).strip()
      if val and not TAG_VALUE_RE.match(val):
        found_passwords.append(val)

    for e_match in EMAIL_RE.finditer(stripped):
      found_emails.append(e_match.group(1).strip())

  if not found_users and found_emails:
    found_users = found_emails[:1]

  primary_user = found_users[0] if found_users else ""
  primary_pass = found_passwords[0] if found_passwords else ""

  # Secondary logins (e.g. username1 + password1) go into custom fields
  custom_fields = []
  for idx in range(1, max(len(found_users), len(found_passwords))):
    if idx < len(found_users):
      custom_fields.append(
          {"name": f"username_{idx + 1}", "value": found_users[idx], "type": 0}
      )
    if idx < len(found_passwords):
      custom_fields.append(
          {"name": f"password_{idx + 1}", "value": found_passwords[idx], "type": 1}
      )

  # Fallback: entry name is a hostname (e.g. github.com.key.gpg)
  base = os.path.basename(name)
  if not uri and DOMAIN_RE.match(base):
    uri = f"https://{base}"

  return primary_user, primary_pass, uri, "\n".join(note_lines), custom_fields


def find_files(input_dir, exts, excludes):
  files = []
  for root, dirs, names in os.walk(input_dir):
    dirs[:] = sorted(d for d in dirs if d not in excludes)
    for n in sorted(names):
      if n.lower().endswith(exts):
        files.append(os.path.join(root, n))
  return files


def is_ram_backed(path):
  """Best-effort check whether path is on a RAM disk (Linux /dev/shm, macOS ram disk)."""
  real = os.path.realpath(path)
  if real.startswith("/dev/shm"):
    return True
  try:
    out = subprocess.run(
        ["df", real], capture_output=True, text=True, check=False
    ).stdout
    return "/dev/shm" in out or "tmpfs" in out or "/dev/ram" in out
  except OSError:
    return False


def write_secret_json(path, data):
  """Create the file with 0600 from the start; refuse to overwrite."""
  fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
  with os.fdopen(fd, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)


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
      "-i", "--input-dir", required=True,
      help="Directory containing your encrypted files (searched recursively).",
  )
  parser.add_argument(
      "-o", "--output", default=default_output,
      help=(
          "Output JSON file, or an existing directory to write"
          " bitwarden_import.json into.\n"
          f"(default: {default_output})"
      ),
  )
  parser.add_argument(
      "-f", "--folder", default="Imported PGP",
      help="Target folder name inside Bitwarden (default: 'Imported PGP').",
  )
  parser.add_argument(
      "--ext", default=".gpg,.pgp",
      help="Comma-separated file extensions to scan (default: .gpg,.pgp).",
  )
  parser.add_argument(
      "--exclude", action="append", default=None,
      help=(
          "Directory name to skip; repeatable (default: bak).\n"
          "Use --exclude '' to include everything."
      ),
  )
  parser.add_argument(
      "-l", "--limit", type=int, default=0,
      help="Only process the first N files (useful for testing).",
  )
  parser.add_argument(
      "--dry-run", action="store_true",
      help="Decrypt and parse files in memory without writing any output file.",
  )
  parser.add_argument(
      "-v", "--verbose", action="store_true",
      help="Print parsed field summary for each file (passwords masked).",
  )
  args = parser.parse_args()

  input_dir = os.path.expanduser(args.input_dir)
  if not os.path.isdir(input_dir):
    sys.exit(f"Error: input directory does not exist: {input_dir}")

  exts = tuple(
      (e if e.startswith(".") else f".{e}").lower()
      for e in (x.strip() for x in args.ext.split(","))
      if e
  )
  excludes = {d for d in (args.exclude if args.exclude is not None else ["bak"]) if d}
  folder_name = args.folder.strip().strip("/") or "Imported PGP"

  # Resolve and validate the output path *before* decrypting anything
  output_path = None
  if not args.dry_run:
    output_path = os.path.expanduser(args.output)
    if os.path.isdir(output_path):
      output_path = os.path.join(output_path, "bitwarden_import.json")
    if os.path.exists(output_path):
      sys.exit(f"Error: {output_path} already exists; delete it first.")
    out_dir = os.path.dirname(os.path.abspath(output_path))
    if not os.path.isdir(out_dir):
      sys.exit(f"Error: output directory does not exist: {out_dir}")
    if not is_ram_backed(out_dir):
      print(
          f"WARNING: {out_dir} is not a RAM disk; the plaintext export will"
          " touch persistent storage. Shred it right after import.",
          file=sys.stderr,
      )

  files = find_files(input_dir, exts, excludes)
  if not files:
    sys.exit(f"No {', '.join(exts)} files found in {input_dir}")
  if args.limit > 0:
    files = files[: args.limit]

  folder_id = str(uuid.uuid4())
  vault_data = {
      "encrypted": False,
      "folders": [{"id": folder_id, "name": folder_name}],
      "items": [],
  }

  missing_pass, binary_skipped, decrypt_failed, truncated = [], [], [], []

  # If two files map to the same entry name (e.g. x.key.gpg and x.key.pgp),
  # keep the full relative path so both stay distinguishable in Bitwarden.
  name_count = {}
  for fp in files:
    n = entry_name(os.path.relpath(fp, input_dir), exts)
    name_count[n] = name_count.get(n, 0) + 1

  excl = f" (excluding dirs: {', '.join(sorted(excludes))})" if excludes else ""
  print(f"Scanning {len(files)} files in {input_dir}{excl}...")

  for filepath in files:
    rel = os.path.relpath(filepath, input_dir)
    name = entry_name(rel, exts)
    display_name = rel if name_count[name] > 1 else name

    if name.lower().endswith(BINARY_SUFFIXES):
      binary_skipped.append(rel)
      continue

    res = subprocess.run(
        ["gpg", "--quiet", "--batch", "--yes", "--decrypt", filepath],
        capture_output=True,
    )
    if res.returncode != 0:
      err = res.stderr.decode("utf-8", "replace").strip().splitlines()
      decrypt_failed.append(f"{rel}: {err[-1] if err else 'unknown error'}")
      continue

    text = decode_text(res.stdout)
    if text is None:
      binary_skipped.append(rel)
      continue

    username, password, uri, notes, custom_fields = parse_free_text(name, text)

    if len(notes.encode("utf-8")) > MAX_NOTES_BYTES:
      notes = notes.encode("utf-8")[:MAX_NOTES_BYTES].decode("utf-8", "ignore")
      notes += "\n[... truncated by pgp_to_bitwarden; see original file ...]"
      truncated.append(rel)

    if not password:
      missing_pass.append(rel)

    if args.verbose:
      masked = ("*" * min(len(password), 12)) if password else "<NONE>"
      extra = f" | +{len(custom_fields)} fields" if custom_fields else ""
      print(
          f"  [OK] {display_name} | user: {username or '<NONE>'} | pass: {masked}"
          f" | uri: {uri or '<NONE>'}{extra}"
      )

    vault_data["items"].append({
        "id": str(uuid.uuid4()),
        "folderId": folder_id,
        "organizationId": None,
        "type": 1,  # Login
        "name": display_name,
        "notes": notes or None,
        "favorite": False,
        "fields": custom_fields,
        "login": {
            "uris": [{"match": None, "uri": uri}] if uri else [],
            "username": username or None,
            "password": password or None,
            "totp": None,
        },
        "collectionIds": None,
    })

  ok = len(vault_data["items"])
  if args.dry_run:
    print(f"\n[DRY RUN] Parsed {ok}/{len(files)} entries. No file written.")
  else:
    write_secret_json(output_path, vault_data)
    print(f"\nDone! Exported {ok}/{len(files)} entries to: {output_path}")
    print(f"Delete it right after importing:  rm -P '{output_path}'")

  def report(title, items, limit=20):
    if not items:
      return
    print(f"\n{title} ({len(items)}):")
    for x in items[:limit]:
      print(f"  - {x}")
    if len(items) > limit:
      print(f"  ... and {len(items) - limit} more.")

  report("Decryption FAILED (not exported)", decrypt_failed)
  report(
      "Binary/non-text files skipped (attach manually in Bitwarden)",
      binary_skipped,
  )
  report(
      f"Notes truncated to {MAX_NOTES_BYTES} bytes (Bitwarden limit) - check"
      " these manually",
      truncated,
  )
  report(
      "No active 'passwd:'/'password:' tag (full text kept in Notes)",
      missing_pass,
  )
  report(
      "Same base name in several files (kept apart by file name)",
      [n for n, c in name_count.items() if c > 1],
  )

  if decrypt_failed:
    sys.exit(2)


if __name__ == "__main__":
  main()
