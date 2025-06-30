#!/bin/bash

# ----------------------------
# Nmap Summary Script (Portable)
# ----------------------------
# - Runs nmap scan
# - Parses open ports
# - Resolves unknown services using editable ports.csv
# - Works offline
# ----------------------------

# Check if nmap is installed
if ! command -v nmap &> /dev/null; then
  echo "Error: nmap is not installed."
  echo "Please install it with your package manager. Example:"
  echo "  sudo apt install nmap     # Debian/Ubuntu"
  echo "  sudo dnf install nmap     # Fedora"
  echo "  sudo pacman -S nmap       # Arch"
  echo "  brew install nmap         # macOS (Homebrew)"
  exit 1
fi

# Check arguments
TARGET=$1
OUTFILE="nmap_output.txt"
PORT_DB="ports.csv"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target>"
  exit 1
fi

if [[ ! -f "$PORT_DB" ]]; then
  echo "Error: $PORT_DB not found."
  echo "Please make sure a 'ports.csv' file is present in the same directory."
  exit 1
fi

# Load port reference from CSV into associative array
declare -A PORT_DESCRIPTIONS
while IFS=',' read -r PORT PROTO DESC; do
  [[ "$PORT" =~ ^#.*$ || -z "$PORT" ]] && continue
  key="${PORT}/${PROTO}"
  PORT_DESCRIPTIONS["$key"]="$DESC"
done < "$PORT_DB"

# Run the scan
echo "[*] Running nmap scan on $TARGET..."
nmap -sS -Pn -n "$TARGET" -oN "$OUTFILE"

echo ""
echo "[*] Scan complete. Summary of open ports for $TARGET:"
echo "--------------------------------------------------------"

# Parse output
grep '^PORT' -A 100 "$OUTFILE" | grep open | while read -r line; do
  PORT=$(echo "$line" | awk '{print $1}' | cut -d'/' -f1)
  PROTO=$(echo "$line" | awk '{print $1}' | cut -d'/' -f2)
  SERVICE=$(echo "$line" | awk '{print $3}')

  key="${PORT}/${PROTO}"
  if [[ -z "$SERVICE" || "$SERVICE" == "unknown" ]]; then
    SERVICE="${PORT_DESCRIPTIONS[$key]}"
    [[ -z "$SERVICE" ]] && SERVICE="Unknown service"
  fi

  echo "Port $PORT/$PROTO is open - $SERVICE"
done
