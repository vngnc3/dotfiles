#!/bin/bash
#
# Preview EXR batch rename - shows what files would be renamed to
# Usage: ./preview_rename.sh [start_number] [padding]
#
# Arguments:
#   start_number - number to start sequential naming from (default: 1)
#   padding      - minimum digit width for zero-padding (default: auto)
#
# Examples:
#   ./preview_rename.sh              # Preview with default settings
#   ./preview_rename.sh 1001         # Start numbering from 1001
#   ./preview_rename.sh 1 4          # Start from 1 with 4-digit padding (0001, 0002...)

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
    echo "No EXR files found in this directory."
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
echo "EXR Batch Rename Preview"
echo "========================================"
echo ""
echo "Found ${#files[@]} EXR file(s)"
echo "Start number: $START_NUM"
echo "Zero-padding: $PADDING digits"
echo ""
echo "Rename plan:"
echo "----------------------------------------"

# Generate preview
counter=$START_NUM
for file in "${files[@]}"; do
    # Extract extension
    ext="${file##*.}"

    # Format new filename with zero-padding
    new_num=$(printf "%0${PADDING}d" "$counter")
    new_name="${new_num}.${ext}"

    # Show rename operation
    if [ "$file" == "$new_name" ]; then
        printf "  %-30s (no change)\n" "$file"
    else
        printf "  %-30s -> %s\n" "$file" "$new_name"
    fi

    counter=$((counter + 1))
done

echo "----------------------------------------"
echo ""
echo "To execute this rename, run: ./rename_exr.sh $START_NUM $PADDING"
echo ""
