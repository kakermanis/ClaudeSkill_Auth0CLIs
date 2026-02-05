#!/bin/sh

# List all Auth0 tenants stored in macOS Keychain
# Usage: ./list-tenants.sh

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

echo "Available Auth0 tenants:"
echo "======================="

# Get tenants from core library
TENANT_LIST=$(_auth0_list_tenants)

if [ -z "$TENANT_LIST" ]; then
    echo "  (none)"
    echo ""
    echo "Use './store-tenant.sh <tenant-name>' to add credentials"
    exit 0
fi

# Parse and display
echo "$TENANT_LIST" | while IFS='|' read -r tenant domain marker; do
    if [ -n "$marker" ]; then
        echo "  • $tenant ($domain) [CURRENT]"
    else
        echo "  • $tenant ($domain)"
    fi
done

echo ""
echo "Use 'eval \$(./load-tenant.sh <tenant-name>)' to load credentials"
