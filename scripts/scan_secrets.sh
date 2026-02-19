#!/bin/bash

echo "🔍 [INFO]  Scanning for potential secrets..."

patterns=(
  "AKIA[0-9A-Z]{16}"                                # AWS Access Key
  "secret[_-]?key[[:space:]]*=[[:space:]]*['\"]?[A-Za-z0-9/\+=]{8,}"  # generic secret key
  "password[[:space:]]*=[[:space:]]*['\"].{4,}"      # password=
  "passphrase[[:space:]]*=[[:space:]]*['\"].{4,}"     # passphrase=
  "Authorization:[[:space:]]*Bearer[[:space:]]+[A-Za-z0-9\-._~+/=]+"  # Bearer token
  "-----BEGIN[[:space:]]+PRIVATE[[:space:]]+KEY-----" # private key block
  "ssh-rsa AAAA[0-9A-Za-z+/]{100,}"                  # SSH public key
  "api[_-]?key[[:space:]]*[:=][[:space:]]*['\"A-Za-z0-9]{8,}" # API key
)

files=$(find . -type f -not -path "./.git/*")
found=false

for file in $files; do
  for pattern in "${patterns[@]}"; do
    if grep -E -q -- "$pattern" "$file"; then
      echo "⚠️  [WARN]  Possible secret in: $file"
      grep -En -- "$pattern" "$file" | sed 's/^/    > /'
      found=true
    fi
  done
done

if [ "$found" = true ]; then
  echo -e "\n❌ [FAIL]  Potential secrets found! Review before publishing."
  exit 1
else
  echo "✅ [OK]    No secrets detected. Safe to push."
fi
