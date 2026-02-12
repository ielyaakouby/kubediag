#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

msg="$1"
cmd="$2"

show_spinner "$msg" &
spinner_pid=$!

# Run the actual command in a subshell and capture exit code
(
  eval "$cmd"
) &

cmd_pid=$!
wait "$cmd_pid"
cmd_status=$?

stop_spinner "$spinner_pid" "$msg"

if [[ $cmd_status -ne 0 ]]; then
  echo "❌ [FAIL]  Command failed: $cmd"
  exit $cmd_status
fi
