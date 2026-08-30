#!/usr/bin/env bash
# Downloads the sample photometry/EMG fixture data (~151 MB, 5 files) used by
# QUICKSTART.md, from a public Google Drive folder. Not committed to git.
#
# Requires: gdown (pip install gdown)
set -euo pipefail

# TODO: replace with the real public Google Drive folder ID once uploaded.
GDRIVE_FOLDER_ID="REPLACE_WITH_GOOGLE_DRIVE_FOLDER_ID"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$SCRIPT_DIR/sample"

mkdir -p "$DEST"

if ! command -v gdown &> /dev/null; then
    echo "gdown not found. Install it with: pip install gdown" >&2
    exit 1
fi

gdown --folder "https://drive.google.com/drive/folders/${GDRIVE_FOLDER_ID}" -O "$DEST"

echo "Sample data downloaded to $DEST"
