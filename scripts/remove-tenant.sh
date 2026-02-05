#!/bin/sh

# Remove Auth0 tenant credentials from macOS Keychain
# Usage: ./remove-tenant.sh <tenant-name>

set -e

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <tenant-name>"
    echo ""
    echo "Example:"
    echo "  $0 dev-tenant"
    exit 1
fi

TENANT_NAME="$1"

# Remove using core library
_auth0_remove_credentials "$TENANT_NAME"

echo "✓ Removed credentials for tenant: ${TENANT_NAME}"

# Remind user to unset env vars if this was the current tenant
if [ "$AUTH0_CUSTOMER" = "$TENANT_NAME" ]; then
    echo ""
    echo "Warning: This was the currently loaded tenant."
    echo "Run the following to unset environment variables:"
    echo "  unset AUTH0_CUSTOMER AUTH0_DOMAIN AUTH0_CLIENT_ID AUTH0_CLIENT_SECRET"
fi
