#!/bin/sh

# Open Auth0 dashboard in browser
# Usage: ./dashboard.sh [tenant-name]

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

# If tenant arg provided, load credentials temporarily
if [ -n "$1" ]; then
    TENANT_NAME="$1"
    CREDS=$(_auth0_get_credentials "$TENANT_NAME" 2>&1) || {
        echo "Error: Tenant '${TENANT_NAME}' not found in keychain"
        exit 1
    }
    DOMAIN=$(echo "$CREDS" | grep "^DOMAIN=" | cut -d'=' -f2-)
else
    # Use currently loaded tenant
    if [ -z "$AUTH0_DOMAIN" ]; then
        echo "Error: No tenant loaded. Use 'eval \$(./load-tenant.sh <tenant>)' first or provide tenant name."
        echo ""
        echo "Usage: $0 [tenant-name]"
        exit 1
    fi
    TENANT_NAME="$AUTH0_CUSTOMER"
    DOMAIN="$AUTH0_DOMAIN"
fi

# Generate dashboard URL using core library
dashboard_url=$(_auth0_dashboard_url "$DOMAIN")

echo "Opening dashboard for: $TENANT_NAME"
echo "URL: $dashboard_url"

# Try to open in default browser
if command -v open > /dev/null 2>&1; then
    open "$dashboard_url"
elif command -v xdg-open > /dev/null 2>&1; then
    xdg-open "$dashboard_url"
else
    echo ""
    echo "Could not open browser automatically. Please open the URL manually."
fi
