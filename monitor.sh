#!/usr/bin/env bash

# Default settings
ROUTER_FILE="routers.txt"
INTERVAL=300

# If more than two arguments are given, show usage and exit
if [ $# -gt 2 ]; then
  printf -- "Usage: %s [router_file] [interval]\n" "$0"
  exit 1
fi

# If at least one argument is given, it's the router file
if [ $# -ge 1 ]; then
  ROUTER_FILE="$1"
fi

# If at least two arguments are given, it's the interval
if [ $# -ge 2 ]; then
  INTERVAL="$2"
  # Validate that interval is a positive integer
  if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
    printf -- "Error: interval must be a positive integer\n"
    exit 1
  fi
fi

# ANSI escape codes for colors and formatting
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BOLD="\033[1m"
RESET="\033[0m"

# Trap Ctrl-C (SIGINT) for a graceful exit
trap cleanup INT
cleanup() {
  printf -- "\nExiting...\n"
  exit 0
}

# We'll keep a global counter that increments each time we refresh
RUN_COUNT=0

# Function to monitor routers
monitor() {
  # $1 is the current run count, passed from the main loop
  local count="$1"

  # Clear the screen
  printf -- "\033c"

  # Print the run count and "Last updated" line in bold
  # E.g. (1) Last updated: Thu Jan  1 00:00:00 PST 2025
  printf -- "%b(%d) Last updated: %s%b\n" "$BOLD" "$count" "$(date)" "$RESET"

  # Table header
  printf -- "%b| Status  | Router           | Log%b\n" "$BOLD" "$RESET"
  printf -- "------------------------------------------------------------------------------------------\n"

  # Read routers from the file
  while IFS= read -r ROUTER || [ -n "$ROUTER" ]; do
    # Skip empty lines
    [ -z "$ROUTER" ] && continue

    # Ping the router (3 pings, 1s timeout each)
    PING_RESULT=$(ping -c 3 -W 1 "$ROUTER" 2>&1)

    # Check for obvious DNS errors or invalid hosts
    if echo "$PING_RESULT" | grep -q "Name or service not known"; then
      STATUS="${RED}INVALID${RESET}"
    elif echo "$PING_RESULT" | grep -qE "(unknown host|invalid|not known|cannot resolve)"; then
      STATUS="${RED}INVALID${RESET}"
    else
      # Extract transmitted and received counts
      TX=$(echo "$PING_RESULT" \
        | grep -oP '(\d+) packets transmitted' \
        | cut -d' ' -f1)
      RX=$(echo "$PING_RESULT" \
        | grep -oP '(\d+) received' \
        | cut -d' ' -f1)

      # If we couldn't extract TX or TX=0, treat as invalid
      if [ -z "$TX" ] || [ "$TX" -eq 0 ]; then
        STATUS="${RED}INVALID${RESET}"
      else
        # Compare transmitted (3) vs received
        if [ "$RX" -eq 3 ]; then
          # Add a single space after "ONLINE" for alignment
          STATUS="${GREEN}ONLINE ${RESET}"
        elif [ "$RX" -eq 0 ]; then
          STATUS="${RED}OFFLINE${RESET}"
        else
          STATUS="${YELLOW}PARTIAL${RESET}"
        fi
      fi
    fi

    # Format the log line (show the first line that mentions packets transmitted or certain errors)
    LOG=$(echo "$PING_RESULT" \
      | grep -E 'packets transmitted|ping: |unknown host|not known|Name or service not known' \
      | head -1)

    # Print the table row
    printf -- "| %-8b | %-16s | %s\n" "$STATUS" "$ROUTER" "$LOG"
  done < "$ROUTER_FILE"

  printf -- "------------------------------------------------------------------------------------------\n"
}

# Main loop
while true; do
  # Increment the run counter
  RUN_COUNT=$(( RUN_COUNT + 1 ))

  # Perform the ping checks, passing the run count to monitor
  monitor "$RUN_COUNT"

  # Poll up to $INTERVAL seconds, giving the user a chance to type "r" or "R" + Enter
  for ((i=1; i<=INTERVAL; i++)); do
    read -r -t 1 line
    if [[ $? -eq 0 ]]; then
      if [[ "$line" == "r" || "$line" == "R" ]]; then
        break
      fi
    fi
  done
done
