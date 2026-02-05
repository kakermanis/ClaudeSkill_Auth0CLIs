#!/bin/sh

# Store Auth0 tenant credentials in macOS Keychain
# Usage: ./store-tenant.sh <tenant-name> [domain] [client-id] [client-secret] [--with-mcp]

set -e

# Source core library
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"

# Parse flags
WITH_MCP=false
for arg in "$@"; do
    case $arg in
        --with-mcp)
            WITH_MCP=true
            shift
            ;;
    esac
done

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <tenant-name> [domain] [client-id] [client-secret] [--with-mcp]"
    echo ""
    echo "Options:"
    echo "  --with-mcp    Also configure Auth0 MCP Server with these credentials"
    echo ""
    echo "Examples:"
    echo "  $0 dev-tenant                                    # Interactive mode"
    echo "  $0 dev-tenant dev.us.auth0.com abc123 secret456  # Non-interactive"
    echo "  $0 dev-tenant --with-mcp                         # Interactive + MCP setup"
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

# Configure MCP Server if requested
if [ "$WITH_MCP" = true ]; then
    echo "Configuring Auth0 MCP Server..."
    if command -v npx > /dev/null 2>&1; then
        npx @auth0/auth0-mcp-server init \
            --auth0-domain "$DOMAIN" \
            --auth0-client-id "$CLIENT_ID" \
            --auth0-client-secret "$CLIENT_SECRET"
        echo "✓ MCP Server configured for tenant: ${TENANT_NAME}"
        echo ""
    else
        echo "⚠ npx not found - skipping MCP Server configuration"
        echo "  Install Node.js to use Auth0 MCP Server"
        echo ""
    fi
fi

echo "Next steps:"
echo "  eval \$(./load-tenant.sh ${TENANT_NAME})  # Load credentials"
echo "  ./list-tenants.sh                         # List all tenants"
