#Set domain from arguement.
domain=$1

#TODO: Add checks for tools required


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