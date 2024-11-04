#!/bin/bash

# Function to get CPU times from /proc/stat
cpu_usage() {
  cpu_line=$(head -n 1 /proc/stat)
  cpu_values=($cpu_line)
  user=${cpu_values[1]}
  nice=${cpu_values[2]}
  system=${cpu_values[3]}
  idle=${cpu_values[4]}
  iowait=${cpu_values[5]}
  irq=${cpu_values[6]}
  softirq=${cpu_values[7]}

  total=$((user + nice + system + idle + iowait + irq + softirq))
  total_idle=$((idle + iowait))
  
  echo "$total $total_idle"
}

# Get initial and final CPU stats
initial=$(cpu_usage)
sleep 1  # Wait to calculate over an interval
final=$(cpu_usage)

# Parse initial and final values
initial_total=$(echo $initial | awk '{print $1}')
initial_idle=$(echo $initial | awk '{print $2}')
final_total=$(echo $final | awk '{print $1}')
final_idle=$(echo $final | awk '{print $2}')

# Calculate CPU usage
total_diff=$((final_total - initial_total))
idle_diff=$((final_idle - initial_idle))
cpu_usage=$((100 * (total_diff - idle_diff) / total_diff))

echo "CPU Usage: $cpu_usage%"
