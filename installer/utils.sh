#!/usr/bin/env bash

show_spinner() {
  local msg="$1"
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local delay=0.1
  local i=0

  tput civis
  printf "\n%s " "$msg"

  while :; do
    i=$(( (i+1) % ${#spinstr} ))
    printf "\r%s %s" "$msg" "${spinstr:$i:1}"
    sleep "$delay"
  done
}

stop_spinner() {
  local spinner_pid=$1
  local msg="$2"
  kill "$spinner_pid" >/dev/null 2>&1 || true
  wait "$spinner_pid" 2>/dev/null || true
  tput cnorm
  printf "\r%s ✅\n\n" "$msg"
}
