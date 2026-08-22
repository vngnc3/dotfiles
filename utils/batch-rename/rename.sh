#!/bin/bash
#
# Batch rename files to sequential numbers (extension-agnostic)
# Usage: ./rename.sh [start_number] [padding] [extension]
#
# Arguments:
#   start_number - number to start sequential naming from (default: 1)
#   padding      - minimum digit width for zero-padding (default: auto)
#   extension    - optional extension filter (e.g., exr, jpg) - if omitted, all files are processed
#
# Examples:
#   ./rename.sh              # Rename all files with default settings
#   ./rename.sh 1001         # Start numbering from 1001
#   ./rename.sh 1 4          # Start from 1 with 4-digit padding (0001, 0002...)
#   ./rename.sh 1 4 exr      # Rename only .exr files
#   ./rename.sh 1 0 jpg      # Rename only .jpg files with auto padding

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Parse arguments
START_NUM=${1:-1}
PADDING=${2:-0}
EXT_FILTER=${3:-}

# Normalize extension filter (strip leading dot if present)
if [ -n "$EXT_FILTER" ]; then
    EXT_FILTER="${EXT_FILTER#.}"
fi

# Find all files (agnostic to extension) and sort version-numerically
# Excludes: directories, hidden files, and the scripts themselves
files=()
SELF_NAME="$(basename "${BASH_SOURCE[0]}")"
for f in *; do
    [ -f "$f" ] || continue
    [[ "$f" == .* ]] && continue
    [[ "$f" == "$SELF_NAME" ]] && continue
    [[ "$f" == "preview_rename.sh" ]] && continue
    [[ "$f" == "rename.sh" ]] && continue
    [[ "$f" == "rename_exr.sh" ]] && continue
    if [ -n "$EXT_FILTER" ]; then
        [[ "$f" == *."$EXT_FILTER" ]] || continue
    fi
    files+=("$f")
done

if [ ${#files[@]} -gt 0 ]; then
    IFS=$'\n' files=($(printf "%s\n" "${files[@]}" | sort -V))
    unset IFS
fi

if [ ${#files[@]} -eq 0 ]; then
    if [ -n "$EXT_FILTER" ]; then
        echo "Error: No .$EXT_FILTER files found in this directory."
    else
        echo "Error: No files found in this directory."
    fi
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
echo "Batch Rename"
echo "========================================"
echo ""
if [ -n "$EXT_FILTER" ]; then
    echo "Found ${#files[@]} .$EXT_FILTER file(s)"
else
    echo "Found ${#files[@]} file(s)"
fi
echo "Start number: $START_NUM"
echo "Zero-padding: $PADDING digits"
if [ -n "$EXT_FILTER" ]; then
    echo "Extension filter: .$EXT_FILTER"
fi
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
trap 'rm -rf "$TMP_DIR"' EXIT

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
    if [[ "$orig_name" == *.* ]]; then
        ext=".${orig_name##*.}"
    else
        ext=""
    fi
    new_num=$(printf "%0${PADDING}d" "$counter")
    new_name="${new_num}${ext}"

    mv "$TMP_DIR/$tmp_name" "$new_name"
    printf "  %-30s -> %s\n" "$orig_name" "$new_name"
    counter=$((counter + 1))
    renamed_count=$((renamed_count + 1))
done < "$TMP_DIR/mapping.txt"

echo "----------------------------------------"
echo ""
echo "Done! Renamed $renamed_count file(s)."
echo ""
