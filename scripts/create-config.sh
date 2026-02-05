#!/bin/sh

# Create config.json for Auth0 Deploy CLI from keychain credentials
# Usage: ./create-config.sh [tenant-name] [output-file]

set -e

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

OUTPUT_FILE="config.json"
TENANT_NAME=""

# Parse arguments
if [ "$#" -eq 0 ]; then
    TENANT_NAME="$AUTH0_CUSTOMER"
elif [ "$#" -eq 1 ]; then
    # Check if it ends with .json (POSIX-compliant)
    case "$1" in
        *.json)
            OUTPUT_FILE="$1"
            TENANT_NAME="$AUTH0_CUSTOMER"
            ;;
        *)
            TENANT_NAME="$1"
            ;;
    esac
elif [ "$#" -eq 2 ]; then
    TENANT_NAME="$1"
    OUTPUT_FILE="$2"
else
    echo "Usage: $0 [tenant-name] [output-file]"
    echo ""
    echo "Examples:"
    echo "  $0                            # Use current tenant, output to config.json"
    echo "  $0 config.dev.json            # Use current tenant, custom output file"
    echo "  $0 dev-tenant                 # Specific tenant, output to config.json"
    echo "  $0 dev-tenant config.dev.json # Specific tenant and output file"
    exit 1
fi

# Check if we have a tenant
if [ -z "$TENANT_NAME" ]; then
    echo "Error: No tenant specified and no tenant currently loaded"
    echo ""
    echo "Either:"
    echo "  1. Load a tenant first: eval \$(./load-tenant.sh <tenant-name>)"
    echo "  2. Specify a tenant: $0 <tenant-name> [output-file]"
    exit 1
fi

# If tenant is already loaded and matches, use env vars
if [ "$TENANT_NAME" = "$AUTH0_CUSTOMER" ] && [ -n "$AUTH0_DOMAIN" ]; then
    DOMAIN="$AUTH0_DOMAIN"
    CLIENT_ID="$AUTH0_CLIENT_ID"
    CLIENT_SECRET="$AUTH0_CLIENT_SECRET"
else
    # Retrieve from keychain using core library
    CREDS=$(_auth0_get_credentials "$TENANT_NAME") || exit 1
    DOMAIN=$(echo "$CREDS" | grep "^DOMAIN=" | cut -d'=' -f2-)
    CLIENT_ID=$(echo "$CREDS" | grep "^CLIENT_ID=" | cut -d'=' -f2-)
    CLIENT_SECRET=$(echo "$CREDS" | grep "^CLIENT_SECRET=" | cut -d'=' -f2-)
fi

# Create config.json
cat > "${OUTPUT_FILE}" <<EOF
{
  "AUTH0_DOMAIN": "${DOMAIN}",
  "AUTH0_CLIENT_ID": "${CLIENT_ID}",
  "AUTH0_CLIENT_SECRET": "${CLIENT_SECRET}",
  "AUTH0_ALLOW_DELETE": false,
  "AUTH0_EXCLUDED_RULES": [],
  "AUTH0_EXCLUDED_CLIENTS": [
    "Auth0 Deploy CLI"
  ],
  "AUTH0_EXPORT_IDENTIFIERS": false
}
EOF

echo "✓ Created ${OUTPUT_FILE} for tenant: ${TENANT_NAME}"
echo "  Domain: ${DOMAIN}"
echo ""
echo "Warning: This file contains sensitive credentials."
echo "Ensure it is added to .gitignore and not committed to version control."
