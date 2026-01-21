#!/bin/bash

# BetterDiscord installation script for macOS
# Downloads, extracts, installs and runs BetterDiscord

set -e

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    log "ERROR: This script is designed for macOS only"
    exit 1
fi

# Check if /tmp directory exists and is writable
if [ ! -d "/tmp" ]; then
    log "ERROR: /tmp directory does not exist"
    exit 1
fi

if [ ! -w "/tmp" ]; then
    log "ERROR: No write permission to /tmp directory"
    exit 1
fi

# Download BetterDiscord
log "Downloading BetterDiscord installer..."
cd /tmp

# Remove any existing download
rm -f BetterDiscord-Mac.zip

# Download the latest BetterDiscord release for macOS
DOWNLOAD_URL="https://github.com/BetterDiscord/Installer/releases/latest/download/BetterDiscord-Mac.zip"

if command -v curl >/dev/null 2>&1; then
    log "Using curl to download..."
    curl -L --progress-bar -o BetterDiscord-Mac.zip "$DOWNLOAD_URL"
elif command -v wget >/dev/null 2>&1; then
    log "Using wget to download..."
    wget --progress=bar:force -O BetterDiscord-Mac.zip "$DOWNLOAD_URL"
else
    log "ERROR: Neither curl nor wget is available"
    exit 1
fi

# Verify download
if [ ! -f "BetterDiscord-Mac.zip" ] || [ ! -s "BetterDiscord-Mac.zip" ]; then
    log "ERROR: Download failed or file is empty"
    exit 1
fi

log "Download completed successfully"

# Extract the ZIP file
log "Extracting BetterDiscord installer..."
unzip -q BetterDiscord-Mac.zip

if [ $? -ne 0 ]; then
    log "ERROR: Failed to extract BetterDiscord-Mac.zip"
    rm -f BetterDiscord-Mac.zip
    exit 1
fi

# Find the .app file
APP_NAME=$(find /tmp -name "*.app" -type d -maxdepth 1 | head -1)

if [ -z "$APP_NAME" ]; then
    log "ERROR: No .app file found in extracted archive"
    rm -f BetterDiscord-Mac.zip
    exit 1
fi

APP_BASENAME=$(basename "$APP_NAME")
log "Found application: $APP_BASENAME"

# Copy to Applications directory
log "Copying $APP_BASENAME to Applications folder..."
if [ -d "/Applications/$APP_BASENAME" ]; then
    log "Removing existing installation..."
    rm -rf "/Applications/$APP_BASENAME"
fi

cp -r "$APP_NAME" "/Applications/"

if [ $? -ne 0 ]; then
    log "ERROR: Failed to copy application to Applications folder"
    rm -f BetterDiscord-Mac.zip
    rm -rf "$APP_NAME"
    exit 1
fi

log "Application copied successfully"

# Clean up
log "Cleaning up temporary files..."
rm -f BetterDiscord-Mac.zip
rm -rf "$APP_NAME"

# Run BetterDiscord installer
log "Starting BetterDiscord installer..."
open "/Applications/$APP_BASENAME"

log "BetterDiscord installer is now running"
log "Please follow the installation prompts to complete the setup"
log "The installer will automatically patch your Discord installation"