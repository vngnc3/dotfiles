#!/bin/bash
#
# Convert a frame sequence to video using ffmpeg
# Usage: ./frames-to-video.sh <first_frame> [framerate]
#
# Arguments:
#   first_frame - first frame filename (e.g., "frame_0123.png" or "0001.exr")
#   framerate   - output frame rate (default: 30)
#
# Examples:
#   ./frames-to-video.sh 0001.png 30
#   ./frames-to-video.sh frame_0123.png 24

set -e

FIRST_FRAME="$1"
FRAMERATE="${2:-30}"

if [ -z "$FIRST_FRAME" ]; then
    echo "Error: First frame filename required."
    echo "Usage: $(basename "$0") <first_frame> [framerate]"
    exit 1
fi

# Extract prefix, numeric portion, and extension from filename
# e.g., "frame_0123.png" -> prefix="frame_", num_str="0123", ext=".png"
if [[ "$FIRST_FRAME" =~ ^(.*[^0-9])?([0-9]+)(\.[^.]+)$ ]]; then
    PREFIX="${BASH_REMATCH[1]}"
    NUM_STR="${BASH_REMATCH[2]}"
    EXT="${BASH_REMATCH[3]}"
    PADDING="${#NUM_STR}"
    START_NUM=$((10#$NUM_STR))
else
    echo "Error: Could not parse frame number from filename: $FIRST_FRAME"
    exit 1
fi

PATTERN="${PREFIX}%0${PADDING}d${EXT}"

if ! command -v ffmpeg &>/dev/null; then
    echo "Error: ffmpeg not found. Install it with 'brew install ffmpeg'."
    exit 1
fi

if ! ffmpeg -encoders 2>/dev/null | grep -q h264_videotoolbox; then
    echo "Error: h264_videotoolbox encoder not found in ffmpeg."
    echo "Reinstall ffmpeg with VideoToolbox support: 'brew reinstall ffmpeg'"
    exit 1
fi

OUTPUT="_$(basename "$(pwd)").mp4"

ffmpeg -start_number "$START_NUM" \
       -framerate "$FRAMERATE" \
       -i "$PATTERN" \
       -c:v h264_videotoolbox \
       -q:v 60 \
       -profile:v high \
       -color_range 2 \
       -pix_fmt yuv420p \
       "$OUTPUT"
