#!/bin/bash
#
# Batch rename EXR files to sequential numbers
# Usage: ./rename_exr.sh [start_number] [padding]
#
# Arguments:
#   start_number - number to start sequential naming from (default: 1)
#   padding      - minimum digit width for zero-padding (default: auto)
#
# Examples:
#   ./rename_exr.sh              # Rename with default settings
#   ./rename_exr.sh 1001         # Start numbering from 1001
#   ./rename_exr.sh 1 4          # Start from 1 with 4-digit padding (0001, 0002...)

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments
START_NUM=${1:-1}
PADDING=${2:-0}

# Find all EXR files and sort numerically by filename
files=()
while IFS= read -r file; do
    files+=("$file")
done < <(ls -1 *.exr 2>/dev/null | sort -V)

if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No EXR files found in this directory."
    exit 1
fi

# Auto-calculate padding if not specified
if [ "$PADDING" -eq 0 ]; then
    total_files=${#files[@]}
    max_num=$((START_NUM + total_files - 1))
    PADDING=${#max_num}
    # Minimum padding of 4 for typical VFX frame sequences
    if [ "$PADDING" -lt 4 ]; then
        PADDING=4
    fi
fi

echo "========================================"
echo "EXR Batch Rename"
echo "========================================"
echo ""
echo "Found ${#files[@]} EXR file(s)"
echo "Start number: $START_NUM"
echo "Zero-padding: $PADDING digits"
echo ""

# Confirm before proceeding
read -p "Are you sure you want to rename these files? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted. No files were renamed."
    exit 0
fi

echo ""
echo "Renaming files..."
echo "----------------------------------------"

# Create temporary directory for staging
TMP_DIR=$(mktemp -d)
trap "rm -rf '$TMP_DIR'" EXIT

# First pass: move to temp names (to avoid conflicts)
for file in "${files[@]}"; do
    tmp_name="$(uuidgen).tmp"
    mv "$file" "$TMP_DIR/$tmp_name"
    echo "$file|$tmp_name" >> "$TMP_DIR/mapping.txt"
done

# Second pass: rename from temp to final names
counter=$START_NUM
renamed_count=0

while IFS='|' read -r orig_name tmp_name; do
    ext="${orig_name##*.}"
    new_num=$(printf "%0${PADDING}d" "$counter")
    new_name="${new_num}.${ext}"

    mv "$TMP_DIR/$tmp_name" "$new_name"
    printf "  %-30s -> %s\n" "$orig_name" "$new_name"
    counter=$((counter + 1))
    renamed_count=$((renamed_count + 1))
done < "$TMP_DIR/mapping.txt"

echo "----------------------------------------"
echo ""
echo "Done! Renamed $renamed_count file(s)."
echo ""
