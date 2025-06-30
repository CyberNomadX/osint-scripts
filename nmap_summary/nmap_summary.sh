#!/bin/bash

# ----------------------------
# Nmap Summary Script v2
# ----------------------------
# - Uses nmap -sV for service detection
# - Falls back to ports.csv for unknowns
# - Suggests tools per open port
# ----------------------------

TARGET=$1
OUTFILE="nmap_output.txt"
PORT_DB="ports.csv"

if ! command -v nmap &> /dev/null; then
  echo "Error: nmap is not installed."
  echo "Install it with:"
  echo "  sudo apt install nmap     # Debian/Ubuntu"
  echo "  sudo dnf install nmap     # Fedora"
  echo "  sudo pacman -S nmap       # Arch"
  echo "  brew install nmap         # macOS"
  exit 1
fi

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target>"
  exit 1
fi

if [[ ! -f "$PORT_DB" ]]; then
  echo "Error: $PORT_DB not found."
  echo "Create or download ports.csv in the same folder."
  exit 1
fi

# Load fallback port descriptions
declare -A PORT_DESCRIPTIONS
while IFS=',' read -r PORT PROTO DESC; do
  [[ "$PORT" =~ ^#.*$ || -z "$PORT" ]] && continue
  key="${PORT}/${PROTO}"
  PORT_DESCRIPTIONS["$key"]="$DESC"
done < "$PORT_DB"

# Tool suggestions
suggest_tool() {
  local service="$1"
  case "$service" in
    ftp) echo "Try: ftp, nmap --script ftp-anon";;
    ssh) echo "Try: ssh, hydra, ssh-audit";;
    telnet) echo "Try: telnet, nmap --script telnet-ntlm-info";;
    http|http-alt) echo "Try: curl, gobuster, nikto, whatweb";;
    https) echo "Try: curl -k, sslscan, whatweb, wappalyzer";;
    mysql) echo "Try: mysql -h <target> -u root -p";;
    mssql) echo "Try: sqsh, nmap --script ms-sql-*";;
    rdp) echo "Try: xfreerdp, rdesktop, ncrack";;
    smb) echo "Try: smbclient, enum4linux-ng, nmap --script smb-*";;
    ldap) echo "Try: ldapsearch, enum4linux-ng";;
    vnc) echo "Try: vncviewer, nmap --script vnc-info";;
    *) echo "No suggestion available";;
  esac
}

echo "[*] Scanning $TARGET with version detection..."
nmap -sS -sV -Pn -n "$TARGET" -oN "$OUTFILE"

echo ""
echo "[*] Summary of open ports for $TARGET:"
echo "-----------------------------------------"

# Parse the relevant lines
awk '/^PORT/{f=1; next} /^Nmap done/{f=0} f' "$OUTFILE" | grep open | while read -r line; do
  PORT_PROTO=$(echo "$line" | awk '{print $1}')
  PORT=$(cut -d'/' -f1 <<< "$PORT_PROTO")
  PROTO=$(cut -d'/' -f2 <<< "$PORT_PROTO")
  SERVICE=$(echo "$line" | awk '{print $3}')
  VERSION=$(echo "$line" | cut -d' ' -f4- | sed -E 's/^[^ ]+ [^ ]+ //')

  [[ -z "$SERVICE" || "$SERVICE" == "unknown" ]] && {
    key="${PORT}/${PROTO}"
    SERVICE="${PORT_DESCRIPTIONS[$key]}"
    [[ -z "$SERVICE" ]] && SERVICE="Unknown service"
    VERSION="N/A"
  }

  echo -e "\nPort $PORT/$PROTO is open - $SERVICE"
  [[ "$VERSION" != "N/A" ]] && echo "  Version: $VERSION"
  echo "  ➡️  $(suggest_tool "$SERVICE")"
done
