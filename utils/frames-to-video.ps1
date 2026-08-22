param(
    [Parameter(Mandatory = $false)]
    [string]$FirstFrame,

    [Parameter(Mandatory = $false)]
    [int]$Framerate = 30
)

<#
.SYNOPSIS
Convert a frame sequence to video using ffmpeg.
.DESCRIPTION
Windows-compatible version that uses the libx264 encoder instead of
h264_videotoolbox (which is macOS-only).
.EXAMPLE
.\frames-to-video.ps1 0001.png 30
.\frames-to-video.ps1 frame_0123.png 24
#>

if (-not $FirstFrame) {
    Write-Host "Error: First frame filename required."
    Write-Host "Usage: frames-to-video.ps1 <first_frame> [framerate]"
    exit 1
}

# Extract prefix, numeric portion, and extension from filename
# e.g., "frame_0123.png" -> prefix="frame_", num_str="0123", ext=".png"
if ($FirstFrame -match '^(.*?)(\d+)(\.[^.]+)$') {
    $Prefix = $Matches[1]
    $NumStr = $Matches[2]
    $Ext = $Matches[3]
    $Padding = $NumStr.Length
    $StartNum = [int]$NumStr
}
else {
    Write-Host "Error: Could not parse frame number from filename: $FirstFrame"
    exit 1
}

$Pattern = $Prefix + ('{0:D' + $Padding + '}' -f $StartNum) + $Ext

if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "Error: ffmpeg not found. Install it with 'choco install ffmpeg' or 'winget install ffmpeg'."
    exit 1
}

$Output = '_' + (Split-Path -Leaf (Get-Location)) + '.mp4'

& ffmpeg -start_number $StartNum `
    -framerate $Framerate `
    -i $Pattern `
    -c:v libx264 `
    -crf 18 `
    -profile:v high `
    -pix_fmt yuv420p `
    $Output

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: ffmpeg failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
