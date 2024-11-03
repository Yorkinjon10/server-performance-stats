#!/bin/bash

# File to save the log
LOG_FILE="system_usage.log"

# Get CPU usage as a percentage for macOS
CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s "%"}')

# Get memory usage as a percentage for macOS
MEMORY_STATS=$(vm_stat)
PAGE_SIZE=$(sysctl -n hw.pagesize)

# Extract values and calculate total and used memory in bytes
FREE_PAGES=$(echo "$MEMORY_STATS" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
ACTIVE_PAGES=$(echo "$MEMORY_STATS" | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
INACTIVE_PAGES=$(echo "$MEMORY_STATS" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
SPECULATIVE_PAGES=$(echo "$MEMORY_STATS" | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')
WIRED_PAGES=$(echo "$MEMORY_STATS" | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')

# Calculate total and used memory in bytes
TOTAL_MEMORY=$(($(echo "$MEMORY_STATS" | grep "Mach Virtual Memory Statistics" | awk '{print ($3 + $5 + $7 + $9 + $11) * $PAGE_SIZE}') ))
USED_MEMORY=$(($(($ACTIVE_PAGES + $INACTIVE_PAGES + $SPECULATIVE_PAGES + $WIRED_PAGES)) * $PAGE_SIZE))
MEMORY_USAGE=$(awk "BEGIN {printf \"%.2f%%\", ($USED_MEMORY / $TOTAL_MEMORY) * 100}")

# Get SSD usage as a percentage for macOS
# Replace `/` with your desired filesystem if different
SSD_USAGE=$(df -h / | grep / | awk '{print $5}')

# Append the current date and time
echo "-----------------------------" >> $LOG_FILE
echo "Date: $(date)" >> $LOG_FILE

# Save the results to the log file
echo "CPU Usage: $CPU_USAGE" >> $LOG_FILE
echo "Memory Usage: $MEMORY_USAGE" >> $LOG_FILE
echo "SSD Usage: $SSD_USAGE" >> $LOG_FILE

# Optionally, display the results in the terminal
echo "CPU Usage: $CPU_USAGE"
echo "Memory Usage: $MEMORY_USAGE"
echo "SSD Usage: $SSD_USAGE"
