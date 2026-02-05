#!/bin/sh

# Load Auth0 tenant credentials from macOS Keychain
# Usage: eval $(./load-tenant.sh <tenant-name>)

set -e

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

if [ "$#" -ne 1 ]; then
    echo "echo 'Usage: eval \$(./load-tenant.sh <tenant-name>)'" >&2
    echo "echo 'Example: eval \$(./load-tenant.sh dev-tenant)'" >&2
    exit 1
fi

TENANT_NAME="$1"

# Get credentials using core library
CREDS=$(_auth0_get_credentials "$TENANT_NAME" 2>&1) || {
    echo "echo 'Error: $CREDS'" >&2
    echo "echo 'Use ./store-tenant.sh to add credentials'" >&2
    exit 1
}

# Parse credentials
DOMAIN=$(echo "$CREDS" | grep "^DOMAIN=" | cut -d'=' -f2-)
CLIENT_ID=$(echo "$CREDS" | grep "^CLIENT_ID=" | cut -d'=' -f2-)
CLIENT_SECRET=$(echo "$CREDS" | grep "^CLIENT_SECRET=" | cut -d'=' -f2-)

# Output export statements (to be eval'd)
cat <<EOF
export AUTH0_CUSTOMER="${TENANT_NAME}"
export AUTH0_DOMAIN="${DOMAIN}"
export AUTH0_CLIENT_ID="${CLIENT_ID}"
export AUTH0_CLIENT_SECRET="${CLIENT_SECRET}"
echo "✓ Loaded Auth0 credentials for: ${TENANT_NAME}"
echo "  Domain: ${DOMAIN}"
echo "  Client ID: ${CLIENT_ID}"
echo ""
echo "Environment variables set:"
echo "  \\\$AUTH0_CUSTOMER, \\\$AUTH0_DOMAIN, \\\$AUTH0_CLIENT_ID, \\\$AUTH0_CLIENT_SECRET"
EOF
