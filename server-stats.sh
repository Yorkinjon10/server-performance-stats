#!/usr/bin/bash

# Detect OS
os_type=$(uname)

if [[ "$os_type" == "Linux" ]]; then
    if command -v mpstat &> /dev/null; then
        cpu_idle=$(mpstat 1 1 | awk '/Average/ {print 100 - $12}')
        echo "CPU Usage on Linux: $cpu_idle%"
    else
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
        echo "CPU Usage on Linux: $cpu_usage%"
    fi
elif [[ "$os_type" == "Darwin" ]]; then
    cpu_usage=$(top -l 1 | grep -E "^CPU" | awk '{print 100 - $7}')
    echo "CPU Usage on macOS: $cpu_usage%"
elif [[ "$os_type" == "CYGWIN"* || "$os_type" == "MINGW"* || "$os_type" == "MSYS"* ]]; then
    echo "CPU Usage on Windows not directly supported in this script."
else
    echo "Unknown operating system: $os_type"
fi
