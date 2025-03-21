#Output file for results
output_file="subdomains_$domain.txt"

#Set domain from argument.
domain="$1"

#Define color variables
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

#Check if subfinder is installed
if which subfinder &> /dev/null; then
    echo "${GREEN} ✅Subfinder is installed.${NC}"
else
    echo "${RED}❌Subfinder is not installed.${NC}"
    echo "${YELLOW}Please install subfinder and try again.${NC}"
    exit 1
fi

#Check if amass is installed
if which amass &> /dev/null; then
    echo "${GREEN} ✅Amass is installed${NC}"
else
    echo "${RED}❌Amass is not installed.${NC}"
    echo "${YELLOW}Please install amass and try again.${NC}"
    exit 1
fi

if [ -z "$domain" ]; then
    echo "${RED}❌Error: No domain provided.${NC}"
    echo "⚠️Usage: $0 <domain>"
    exit 1
fi

echo "${YELLOW}===>${NC}Running Subfinder on $domain"
subfinder -d $domain -o subfinder_results.txt

echo "${YELLOW}===>${NC}Running Amass on $domain (passive mode)"
echo "⏳Patience...(this may take a while)"
amass enum -passive -d $domain -o amass_results.txt

echo "${YELLOW}===>${NC}Merging, organizing and sorting results..."
echo "${YELLOW}===>${NC}Removing duplicates...(Not working currently)"
cat subfinder_results.txt amass_results.txt | sort -u > $output_file

echo "${GREEN}*Enumeration complete.${NC} Results saved to $output_file"

echo "${YELLOW}===>${NC}Cleaning up directories..."
rm subfinder_results.txt amass_results.txt
echo "${GREEN}*Cleanup complete.${NC}"
echo "${YELLOW}===>${NC}Exiting..."

#TODO:
# Is it possible to add a feature to filter for interesting results?
# Removeing duplicates is not working properly. Need to fix that.