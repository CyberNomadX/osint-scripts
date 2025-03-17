
#Define color variables
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

#Set domain from arguement.
domain=$1

#Check if subfinder is installed
if command -v subfinder >&2; then
    echo "${GREEN} ✅Subfinder is installed.${NC}"
else
    echo "${RED}❌Subfinder is not installed.${NC}"
    echo "${YELLOW}Please install subfinder and try again.${NC}"
    read -p "${YELLOW}Press [Enter] to exit the process.${NC}"
    exit 1
fi

#Check if amass is installed
if command -v amass >&2; then
    echo "${GREEN} ✅Amass is installed${NC}"
else
    echo "${RED}❌Amass is not installed.${NC}"
    echo "${YELLOW}Please install amass and try again.${NC}"
    read -p "${YELLOW}Press [Enter] to exit the process.${NC}"
    exit 1
fi

if [ -z "$domain" ]; then
    echo "[*] Usage: $0 <domain>"
    exit 1
fi

#Output file for results
OutputFile="subdomains_$domain.txt"

echo "${YELLOW}===>${NC}Running Subfinder on $domain"
subfinder -d $domain -o subfinder_results.txt

echo "${YELLOW}===>${NC}Running Amass on $domain (passive mode)"
echo "⏳Patience...(this may take a while)"
amass enum -passive -d $domain -o amass_results.txt

echo "${YELLOW}===>${NC}Merging, organizing and sorting results..."
echo "${YELLOW}===>${NC}Removing duplicates..."
cat subfinder_results.txt amass_results.txt | sort -u > $OutputFile

echo "${GREEN}*Enumeration complete.${NC} Results saved to $OutputFile"