#!/usr/bin/env bash

set -euo pipefail

DEFAULT_PAPER="letter"
PAPER_SIZE="$DEFAULT_PAPER"
OUTFILE=""
INPUT_FILES=()

usage() {
    cat <<EOF
Usage: $0 [options] file1.pdf file2.pdf ... -o outfile.pdf

Options:
  -o OUTFILE.pdf       Specify the output PDF filename (required)
  -p, --paper FORMAT   Set output paper size (default: $DEFAULT_PAPER)
  -h, --help           Show this help message

Common Paper Formats:
  letter        US Letter (8.5 x 11 in) [Default]
  a4            Standard A4 (210 x 297 mm)
  legal         US Legal (8.5 x 14 in)
  a3            Standard A3 (297 x 420 mm)
  a5            Standard A5 (148 x 210 mm)
  ledger        US Ledger / Tabloid (11 x 17 in)
  b5            Standard B5 (176 x 250 mm)
EOF
    exit 1
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o)
            if [[ -n "${2:-}" ]]; then
                OUTFILE="$2"
                shift 2
            else
                echo "Error: -o flag requires an output filename." >&2
                usage
            fi
            ;;
        -p|--paper)
            if [[ -n "${2:-}" ]]; then
                PAPER_SIZE="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
                shift 2
            else
                echo "Error: -p/--paper flag requires a format string." >&2
                usage
            fi
            ;;
        -h|--help)
            usage
            ;;
        *)
            INPUT_FILES+=("$1")
            shift
            ;;
    esac
done

# Validation checks
if [[ -z "$OUTFILE" ]]; then
    echo "Error: Output file (-o outfile.pdf) is required." >&2
    usage
fi

if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
    echo "Error: At least one input PDF file must be provided." >&2
    usage
fi

# Run Ghostscript to merge and force selected paper size
gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite \
   -sPAPERSIZE="$PAPER_SIZE" \
   -dFIXEDMEDIA \
   -dPDFFitPage \
   -sOutputFile="$OUTFILE" \
   "${INPUT_FILES[@]}"