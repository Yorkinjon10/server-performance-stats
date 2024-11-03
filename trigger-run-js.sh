#!/bin/bash

# Path to your JavaScript file
JS_FILE="backup.js"

# Loop to run the JavaScript file every 5 seconds
while true; do
   # Run the JavaScript file with Node.js
   node $JS_FILE
   
   # Wait for 5 seconds before the next execution
   sleep 86400

done
