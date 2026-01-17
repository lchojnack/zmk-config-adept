#!/bin/bash

# Script to flash firmware to XIAO-SENSE device
# Usage: ./flash-firmware.sh [adept|reset]
#
# Examples:
#   ./flash-firmware.sh adept     # Flash adept keyboard
#   ./flash-firmware.sh reset     # Flash settings reset

set -e

OUTPUT_DIR="firmware"
TARGET="${1:-adept}"

# Determine firmware file to flash
case "$TARGET" in
    adept)
        echo "Looking for adept_board firmware..."
        FIRMWARE=$(find "$OUTPUT_DIR" -name "*adept_board*.uf2" -type f | head -n 1)
        DEVICE_NAME="adept keyboard"
        ;;
    reset)
        echo "Looking for settings_reset firmware..."
        FIRMWARE=$(find "$OUTPUT_DIR" -name "*settings_reset*.uf2" -type f | head -n 1)
        DEVICE_NAME="device (settings reset)"
        ;;
    *)
        echo "Error: Unknown target '$TARGET'"
        echo "Usage: ./flash-firmware.sh [adept|reset]"
        exit 1
        ;;
esac

if [ -z "$FIRMWARE" ]; then
    echo "Error: Firmware for $DEVICE_NAME not found in $OUTPUT_DIR/"
    echo "Run ./download-firmware.sh first to download firmware"
    exit 1
fi

echo "Found: $FIRMWARE"
echo ""
echo "Waiting for XIAO-SENSE device (10s timeout)..."
echo "Put the $DEVICE_NAME in bootloader mode (double-tap reset button)"

# Wait for device to appear (10 second timeout)
MOUNT_POINT=""
TIMEOUT=10
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    for path in /media/$USER/XIAO-SENSE /media/XIAO-SENSE /run/media/$USER/XIAO-SENSE; do
        if [ -d "$path" ]; then
            MOUNT_POINT="$path"
            break 2
        fi
    done
    sleep 1
    ELAPSED=$((ELAPSED + 1))
    echo -n "."
done
echo ""

if [ -z "$MOUNT_POINT" ]; then
    echo "Error: XIAO-SENSE device not found"
    echo "Please put the $DEVICE_NAME in bootloader mode (double-tap reset button)"
    exit 1
fi

echo "Found device at: $MOUNT_POINT"
echo "Copying firmware to $DEVICE_NAME..."

cp "$FIRMWARE" "$MOUNT_POINT/"
sync

echo ""
echo "✓ Firmware flashed successfully to $DEVICE_NAME!"
echo "Device will reboot automatically"
