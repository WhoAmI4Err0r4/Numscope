#!/data/data/com.termux/files/usr/bin/bash
# NumScope — privacy-safe phone number information tool for Termux
# Does NOT track live location or reveal GPS coordinates.

set -u
GREEN='\033[1;32m'; CYAN='\033[1;36m'; YELLOW='\033[1;33m'
RED='\033[1;31m'; RESET='\033[0m'

banner() {
  clear
  printf "${GREEN}"
  cat <<'EOF'
 _   _                 ____
| \ | |_   _ _ __ ___ / ___|  ___ ___  _ __   ___
|  \| | | | | '_ ` _ \\___ \ / __/ _ \| '_ \ / _ \
| |\  | |_| | | | | | |___) | (_| (_) | |_) |  __/
|_| \_|\__,_|_| |_| |_|____/ \___\___/| .__/ \___|
                                      |_|
          NUMSCOPE • TERMUX
      Phone Number Info • Educational
EOF
  printf "${RESET}\n"
  echo -e "${YELLOW}No live location tracking. Consent and privacy first.${RESET}\n"
}

install_deps() {
  pkg update -y
  pkg install -y python
  python -m pip install --upgrade pip
  python -m pip install phonenumbers
  echo -e "${GREEN}[+] NumScope is ready.${RESET}"
}

lookup_number() {
  python -c "import phonenumbers" 2>/dev/null || {
    echo -e "${RED}[!] Run option 1 first.${RESET}"; return
  }

  NUMBER="$1" python - <<'PY'
import os, phonenumbers
from phonenumbers import geocoder, carrier, timezone

raw = os.environ["NUMBER"].strip()
try:
    n = phonenumbers.parse(raw, None)
except Exception:
    print("[!] Invalid format. Use international format, e.g. +8801XXXXXXXXX")
    raise SystemExit(1)

print("\n=== NumScope Result ===")
print("Valid       :", phonenumbers.is_valid_number(n))
print("Possible    :", phonenumbers.is_possible_number(n))
print("Country     :", phonenumbers.region_code_for_number(n) or "Unknown")
print("Description :", geocoder.description_for_number(n, "en") or "Unknown")
print("Carrier     :", carrier.name_for_number(n, "en") or "Unknown")
tz = timezone.time_zones_for_number(n)
print("Time zones  :", ", ".join(tz) if tz else "Unknown")
print("\nThese are numbering-plan/database details, not live GPS location.")
PY
}

main() {
  banner
  while true; do
    echo "1) Install dependencies"
    echo "2) Analyze a phone number"
    echo "3) Consent-based location help"
    echo "0) Exit"
    echo
    read -rp "numscope > " choice
    case "$choice" in
      1) install_deps ;;
      2) read -rp "Phone number (+country code): " n; lookup_number "$n" ;;
      3) echo -e "${CYAN}For actual GPS location, the person must actively share it${RESET}"; echo "using a consent-based service such as Google Maps location sharing." ;;
      0) exit 0 ;;
      *) echo -e "${RED}[!] Invalid option.${RESET}" ;;
    esac
    echo; read -rp "Press Enter to continue..."; banner
  done
}
main
