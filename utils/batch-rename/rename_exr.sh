#!/bin/bash
#
# Batch rename EXR files to sequential numbers (DEPRECATED)
# This script is kept for backwards compatibility and now delegates to
# the extension-agnostic rename.sh. For new usage, prefer ./rename.sh
# which handles any file extension (and optionally filters by extension).
#
# Usage: ./rename_exr.sh [start_number] [padding] [extension]
#   If extension is omitted, all files are processed (agnostic).
#   To retain legacy EXR-only behavior, explicitly pass "exr":
#     ./rename_exr.sh 1 4 exr
#
# See: ./rename.sh for full documentation.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Note: rename_exr.sh is deprecated, use rename.sh (extension-agnostic) instead." >&2
echo "" >&2

exec "$SCRIPT_DIR/rename.sh" "$@"
