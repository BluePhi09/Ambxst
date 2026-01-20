#!/usr/bin/env bash
# Migration script to fix brightness idle timeout configuration
# This script updates the user's system.json file with the brightness bug fix

set -e

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/Ambxst/config/system.json"

echo "=== Ambxst Brightness Fix Migration ==="
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "✓ No existing system.json found. The fix will be applied automatically on first run."
    exit 0
fi

echo "Found existing configuration: $CONFIG_FILE"
echo ""

# Check if the file contains the old buggy command
if grep -q '"onTimeout": "ambxst brightness 10 -s"' "$CONFIG_FILE"; then
    echo "⚠ Old brightness configuration detected!"
    echo ""
    echo "Creating backup..."
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "✓ Backup created: ${CONFIG_FILE}.backup.*"
    echo ""
    
    echo "Applying fix..."
    # Use sed to replace the buggy command with the fixed one
    sed -i 's/"onTimeout": "ambxst brightness 10 -s"/"onTimeout": "ambxst brightness -s \&\& ambxst brightness 10"/g' "$CONFIG_FILE"
    
    echo "✓ Configuration updated!"
    echo ""
    echo "The fix has been applied. Please restart Ambxst:"
    echo "  ambxst reload"
    echo ""
elif grep -q '"onTimeout": "ambxst brightness -s && ambxst brightness 10"' "$CONFIG_FILE"; then
    echo "✓ Configuration already has the fix applied. No changes needed."
    echo ""
else
    echo "⚠ Could not find the brightness idle configuration."
    echo "  You may need to manually update your config file."
    echo ""
    echo "  Edit: $CONFIG_FILE"
    echo "  Find the line with: \"timeout\": 150"
    echo "  Change \"onTimeout\" to: \"ambxst brightness -s && ambxst brightness 10\""
    echo ""
fi
