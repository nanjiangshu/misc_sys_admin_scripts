#!/bin/bash

# Create a temporary directory
TMPDIR=$(mktemp -d)

# Ensure TMPDIR gets removed on script exit
trap 'rm -rf "$TMPDIR"' EXIT

# File size in megabytes
FILE_SIZE_MB=200
BLOCK_SIZE=1024
BLOCKS_COUNT=$((FILE_SIZE_MB * BLOCK_SIZE))

# Filename of the temp file
FILENAME="$TMPDIR/testfile"

# Create a file with dd command
START_TIME=$(date +%s.%N)
dd if=/dev/zero of="$FILENAME" bs="$BLOCK_SIZE" count="$BLOCKS_COUNT" conv=fdatasync
END_TIME=$(date +%s.%N)

# Calculate time difference
TIME_DIFF=$(echo "$END_TIME - $START_TIME" | bc)

echo "Time taken to write $FILE_SIZE_MB MB on disk: $TIME_DIFF seconds"