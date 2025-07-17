#!/bin/bash

LOG_DIR="./logs"

# Simulated execution time
EXEC_TIME="2023-02-16T21:36:00"
EXEC_EPOCH=$(date -jf "%Y-%m-%dT%H:%M:%S" "$EXEC_TIME" +"%s")
START_EPOCH=$((EXEC_EPOCH - 600)) # 10 minutes before

echo "Executed at ${EXEC_TIME}.000"

for file in "$LOG_DIR"/*.log; do
  count=0
  while IFS= read -r line; do
    # Extract timestamp and status code
    timestamp=$(echo "$line" | grep -oE '\[[^]]+\]' | tr -d '[]')
    status=$(echo "$line" | awk '{print $9}')
    
    # Convert timestamp to epoch
    line_epoch=$(perl -e '
      use Time::Piece;
      my $t = Time::Piece->strptime($ARGV[0], "%d/%b/%Y:%H:%M:%S %z");
      print $t->epoch;
    ' "$timestamp")

    # Count if within range and status is 500
    if [ "$line_epoch" -ge "$START_EPOCH" ] && [ "$line_epoch" -le "$EXEC_EPOCH" ] && [ "$status" = "500" ]; then
      count=$((count + 1))
    fi
  done < "$file"

  echo "Total error >>> $count HTTP 500 errors in ./${file##*/} in the last 10 minutes."
done
