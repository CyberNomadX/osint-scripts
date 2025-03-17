
#Define color variables
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

#Set domain from arguement.
domain=$1

#TODO: Add checks for tools required
#Check if subfinder is installed
if command -v subfinder >&2; then
    echo "${GREEN} ✅ Subfinder is installed"
else
    echo "${RED}❌ Subfinder is not installed"
    echo "Please install subfinder and try again"
    read -p "Press [Enter] to exit the process"
    exit 1
fi

#Check if amass is installed
if command -v amass >&2; then
    echo "${GREEN} ✅ Amass is installed"
else
    echo "${RED}❌ Amass is not installed"
    echo "Please install amass and try again"
    read -p "Press [Enter] to exit the process"
    exit 1
fi

if [ -z "$domain" ]; then
    echo "[*] Usage: $0 <domain>"
    exit 1
fi

#Output file for results
OutputFile="subdomains_$domain.txt"

echo "[*] Running Subfinder on $domain"
subfinder -d $domain -o subfinder_results.txt

echo "[*] Running Amass on $domain (passive mode)"
echo "Patience...(this may take a while)"
amass enum -passive -d $domain -o amass_results.txt

echo "[*] Merging, organizing and sorting results"
echo "[*] Removing duplicates"
cat subfinder_results.txt amass_results.txt | sort -u > $OutputFile

echo "[*] Enumeration complete. Results saved to $OutputFile"