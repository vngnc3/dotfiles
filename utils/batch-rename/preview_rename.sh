#!/bin/bash
#
# Preview batch rename - shows what files would be renamed to
# Usage: ./preview_rename.sh [start_number] [padding] [extension]
#
# Arguments:
#   start_number - number to start sequential naming from (default: 1)
#   padding      - minimum digit width for zero-padding (default: auto)
#   extension    - optional extension filter (e.g., exr, jpg) - if omitted, all files are processed
#
# Examples:
#   ./preview_rename.sh              # Preview all files with default settings
#   ./preview_rename.sh 1001         # Start numbering from 1001
#   ./preview_rename.sh 1 4          # Start from 1 with 4-digit padding (0001, 0002...)
#   ./preview_rename.sh 1 4 exr      # Preview only .exr files
#   ./preview_rename.sh 1 0 jpg      # Preview only .jpg files with auto padding

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
    # Must be a regular file
    [ -f "$f" ] || continue
    # Skip hidden files
    [[ "$f" == .* ]] && continue
    # Skip scripts themselves
    [[ "$f" == "$SELF_NAME" ]] && continue
    [[ "$f" == "preview_rename.sh" ]] && continue
    [[ "$f" == "rename.sh" ]] && continue
    [[ "$f" == "rename_exr.sh" ]] && continue
    # Optional extension filter
    if [ -n "$EXT_FILTER" ]; then
        [[ "$f" == *."$EXT_FILTER" ]] || continue
    fi
    files+=("$f")
done

# Sort version-numerically (handles 1, 2, 10 correctly)
if [ ${#files[@]} -gt 0 ]; then
    IFS=$'\n' files=($(printf "%s\n" "${files[@]}" | sort -V))
    unset IFS
fi

if [ ${#files[@]} -eq 0 ]; then
    if [ -n "$EXT_FILTER" ]; then
        echo "No .$EXT_FILTER files found in this directory."
    else
        echo "No files found in this directory."
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
echo "Batch Rename Preview"
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
echo "Rename plan:"
echo "----------------------------------------"

# Generate preview
counter=$START_NUM
for file in "${files[@]}"; do
    # Extract extension (preserve original, handle files without extension)
    if [[ "$file" == *.* ]]; then
        ext=".${file##*.}"
    else
        ext=""
    fi

    # Format new filename with zero-padding
    new_num=$(printf "%0${PADDING}d" "$counter")
    new_name="${new_num}${ext}"

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
# Point to the generic rename script (with optional extension arg)
if [ -n "$EXT_FILTER" ]; then
    echo "To execute this rename, run: ./rename.sh $START_NUM $PADDING $EXT_FILTER"
else
    echo "To execute this rename, run: ./rename.sh $START_NUM $PADDING"
fi
echo ""
