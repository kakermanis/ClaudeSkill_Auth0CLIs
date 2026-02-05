#!/bin/sh

# Store Auth0 tenant credentials in macOS Keychain
# Usage: ./store-tenant.sh <tenant-name> [domain] [client-id] [client-secret]

set -e

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <tenant-name> [domain] [client-id] [client-secret]"
    echo ""
    echo "Examples:"
    echo "  $0 dev-tenant                                    # Interactive mode"
    echo "  $0 dev-tenant dev.us.auth0.com abc123 secret456  # Non-interactive"
    exit 1
fi

TENANT_NAME="$1"

# Interactive mode if not all args provided
if [ "$#" -eq 1 ]; then
    echo "Adding Auth0 credentials for: $TENANT_NAME"
    echo ""

    printf "Domain: "
    read -r DOMAIN

    printf "Client ID: "
    read -r CLIENT_ID

    printf "Client Secret: "
    stty -echo
    read -r CLIENT_SECRET
    stty echo
    echo ""
    echo ""
else
    DOMAIN="$2"
    CLIENT_ID="$3"
    CLIENT_SECRET="$4"
fi

# Store using core library
_auth0_store_credentials "$TENANT_NAME" "$DOMAIN" "$CLIENT_ID" "$CLIENT_SECRET" || exit 1

echo "✓ Successfully stored credentials for tenant: ${TENANT_NAME}"
echo "  Domain: ${DOMAIN}"
echo "  Client ID: ${CLIENT_ID}"
echo ""
echo "Next steps:"
echo "  eval \$(./load-tenant.sh ${TENANT_NAME})  # Load credentials"
echo "  ./list-tenants.sh                         # List all tenants"
