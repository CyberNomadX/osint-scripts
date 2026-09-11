# osint-scripts

A collection of passive OSINT and attack surface reconnaissance scripts for subdomain enumeration, infrastructure analysis, and threat intelligence gathering. All tools are designed for **authorized use only** against domains you own or have explicit permission to audit.

---

## Scripts

### `subscan` — Subdomain Enumeration
Runs subfinder and amass in parallel, merges and deduplicates results, and outputs a sorted list of discovered subdomains. Results are also written to `domains.txt` for direct use with `asaudit`.

### `asaudit` — Attack Surface Audit
Performs passive analysis on one or more domains: IP resolution, CNAME chain (subdomain takeover indicator), HTTP/HTTPS redirect chains, TLS certificate info, security headers, SPF/DMARC email security, MX records, CAA records, and name servers. Produces a per-domain `.txt` report.

### `shodan_query` — Shodan Recon
Queries the Shodan API for IPs associated with a target domain using a set of focused queries (open ports, exposed services, dev subdomains, etc.). Optionally runs nmap against discovered IPs.

---

## Dependencies

| Tool | Required By | Install |
|------|-------------|---------|
| `subfinder` | subscan | [projectdiscovery.io/open-source/subfinder](https://projectdiscovery.io/open-source/subfinder) |
| `amass` | subscan | `go install github.com/owasp-amass/amass/v4/...@master` |
| `curl` | asaudit | Pre-installed on most systems |
| `dig` | asaudit | `apt install dnsutils` / `brew install bind` |
| `openssl` | asaudit | Pre-installed on most systems |
| `shodan` | shodan_query | `pip install shodan` → `shodan init <API_KEY>` |
| `nmap` | shodan_query (optional) | `apt install nmap` / `brew install nmap` |

---

## Usage

### Recommended workflow — full recon pipeline

```bash
# 1. Enumerate subdomains and write domains.txt
./subscan example.com

# 2. Audit attack surface across all discovered subdomains
./asaudit
# Results land in asaudit_results/<subdomain>.txt
```

### Run tools independently

```bash
# Enumerate subdomains
./subscan example.com
./subscan -f example.com   # with filter (WIP)

# Audit specific domains
./asaudit example.com www.example.com api.example.com

# Shodan recon — interactive
./shodan_query

# Shodan recon — non-interactive (domain, limit, output file)
./shodan_query example.com 20 ips.txt
```

---

## Output

- `subscan` → `subdomains_<domain>.txt`, `domains.txt`
- `asaudit` → `asaudit_results/<domain>.txt` (per-domain report)
- `shodan_query` → `<IP_FILE>` (default: `shodan_scan.txt`)

---

## Notes

- `amass` passive mode can take several minutes per domain — this is expected.
- `shodan_query` requires a Shodan API key. Free-tier keys have limited query credits.
- `nmap -sS` (SYN scan) requires root/sudo. The script falls back to `-sT` automatically if not root.
- All tools operate **passively** and make no direct connections to scan targets except `asaudit`'s HTTP/TLS checks (which are standard browser-equivalent requests).

---

## License

MIT — see [LICENSE](LICENSE)