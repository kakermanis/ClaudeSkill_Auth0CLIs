#!/bin/sh

# Show currently loaded Auth0 tenant
# Usage: ./current-tenant.sh

if [ -z "$AUTH0_CUSTOMER" ]; then
    echo "No tenant currently loaded"
    echo ""
    echo "Use 'eval \$(./load-tenant.sh <tenant-name>)' to load credentials"
    echo "Use './list-tenants.sh' to see available tenants"
    exit 0
fi

echo "Current tenant: $AUTH0_CUSTOMER"
echo "Domain: $AUTH0_DOMAIN"
echo "Client ID: $AUTH0_CLIENT_ID"
echo ""
echo "Environment variables:"
echo "  AUTH0_CUSTOMER=$AUTH0_CUSTOMER"
echo "  AUTH0_DOMAIN=$AUTH0_DOMAIN"
echo "  AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID"
echo "  AUTH0_CLIENT_SECRET=***"
