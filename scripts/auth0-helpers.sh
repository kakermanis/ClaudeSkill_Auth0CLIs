#!/bin/sh

# Auth0 Helper Functions for macOS Keychain Integration
# Source this file in your shell: source /path/to/scripts/auth0-helpers.sh
#
# This file wraps the standalone scripts and core library to provide
# convenient functions for interactive shell use.

# Detect script directory (works in both bash and zsh)
if [ -n "$BASH_SOURCE" ]; then
    _AUTH0_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    _AUTH0_SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    echo "Warning: Unable to detect script directory. Functions may not work correctly."
    return 1
fi

# Source core library for direct access to helper functions
. "${_AUTH0_SCRIPT_DIR}/lib/auth0-core.sh"

# Check dependencies on first load (only once per session)
if [ -z "$AUTH0_HELPERS_LOADED" ]; then
    if [ -f "${_AUTH0_SCRIPT_DIR}/check-dependencies.sh" ]; then
        # Run dependency check
        if ! "${_AUTH0_SCRIPT_DIR}/check-dependencies.sh" --quiet; then
            echo ""
            echo "⚠ Some dependencies are missing. Run './scripts/check-dependencies.sh' for details."
            echo ""
        fi
    fi
    export AUTH0_HELPERS_LOADED=true
fi

# Add new tenant credentials (interactive)
auth0_add() {
    "${_AUTH0_SCRIPT_DIR}/store-tenant.sh" "$@"
}

# Load tenant credentials into environment
auth0_load() {
    if [ -z "$1" ]; then
        echo "Usage: auth0_load <tenant_name>"
        return 1
    fi

    # Use eval to execute the load script's output
    eval "$("${_AUTH0_SCRIPT_DIR}/load-tenant.sh" "$1")"
}

# Unload current tenant (clear environment variables)
auth0_unload() {
    if [ -z "$AUTH0_CUSTOMER" ]; then
        echo "No tenant currently loaded"
        return 0
    fi

    local previous="$AUTH0_CUSTOMER"
    unset AUTH0_CUSTOMER AUTH0_DOMAIN AUTH0_CLIENT_ID AUTH0_CLIENT_SECRET
    echo "✓ Unloaded tenant: $previous"
}

# Remove tenant credentials from keychain
auth0_remove() {
    "${_AUTH0_SCRIPT_DIR}/remove-tenant.sh" "$@"
}

# List all stored tenants
auth0_list() {
    "${_AUTH0_SCRIPT_DIR}/list-tenants.sh" "$@"
}

# Show currently loaded tenant
auth0_current() {
    "${_AUTH0_SCRIPT_DIR}/current-tenant.sh" "$@"
}

# Generate config.json for Auth0 Deploy CLI
auth0_generate_config() {
    "${_AUTH0_SCRIPT_DIR}/create-config.sh" "$@"
}

# Open Auth0 dashboard in browser
auth0_dashboard() {
    local tenant="$1"

    # If tenant is provided, temporarily load it for dashboard URL
    if [ -n "$tenant" ] && [ "$tenant" != "$AUTH0_CUSTOMER" ]; then
        "${_AUTH0_SCRIPT_DIR}/dashboard.sh" "$tenant"
    elif [ -n "$AUTH0_DOMAIN" ]; then
        "${_AUTH0_SCRIPT_DIR}/dashboard.sh"
    else
        echo "Error: No tenant loaded. Use 'auth0_load <tenant>' first or provide tenant name."
        return 1
    fi
}

# Deploy to current tenant using Auth0 Deploy CLI
auth0_deploy() {
    local config_dir="${1:-Auth0Tenant}"

    if [ -z "$AUTH0_CUSTOMER" ]; then
        echo "Error: No tenant loaded"
        echo "Use 'auth0_load <tenant>' first"
        return 1
    fi

    if [ ! -d "$config_dir" ]; then
        echo "Error: Configuration directory '$config_dir' not found"
        return 1
    fi

    echo "Deploying to tenant: $AUTH0_CUSTOMER"
    echo "Domain: $AUTH0_DOMAIN"
    echo ""

    # Auth0 Deploy CLI will use environment variables
    if command -v a0deploy > /dev/null 2>&1; then
        a0deploy import -i "$config_dir" --verbose
    else
        echo "Error: a0deploy command not found"
        echo "Install with: npm install -g auth0-deploy-cli"
        return 1
    fi
}

# Export tenant configuration using Auth0 Deploy CLI
auth0_export() {
    local output_dir="${1:-Auth0Tenant}"

    if [ -z "$AUTH0_CUSTOMER" ]; then
        echo "Error: No tenant loaded"
        echo "Use 'auth0_load <tenant>' first"
        return 1
    fi

    echo "Exporting configuration from tenant: $AUTH0_CUSTOMER"
    echo "Domain: $AUTH0_DOMAIN"
    echo "Output: $output_dir"
    echo ""

    # Auth0 Deploy CLI will use environment variables
    if command -v a0deploy > /dev/null 2>&1; then
        a0deploy export -f yaml -o "$output_dir"
    else
        echo "Error: a0deploy command not found"
        echo "Install with: npm install -g auth0-deploy-cli"
        return 1
    fi
}

# MCP Server: Check current session
auth0_mcp_session() {
    if [ "$AUTH0_MCP_AVAILABLE" = "false" ]; then
        echo "Auth0 MCP Server is not available"
        echo "Run './scripts/check-dependencies.sh' for installation instructions"
        return 1
    fi

    if command -v npx > /dev/null 2>&1; then
        npx @auth0/auth0-mcp-server session
    else
        echo "Error: npx not found"
        echo "Install Node.js to use Auth0 MCP Server"
        return 1
    fi
}

# MCP Server: Logout from current tenant
auth0_mcp_logout() {
    if [ "$AUTH0_MCP_AVAILABLE" = "false" ]; then
        echo "Auth0 MCP Server is not available"
        echo "Run './scripts/check-dependencies.sh' for installation instructions"
        return 1
    fi

    if command -v npx > /dev/null 2>&1; then
        npx @auth0/auth0-mcp-server logout
        echo "✓ Logged out of Auth0 MCP Server"
    else
        echo "Error: npx not found"
        echo "Install Node.js to use Auth0 MCP Server"
        return 1
    fi
}

# MCP Server: Initialize with current tenant
auth0_mcp_init() {
    if [ "$AUTH0_MCP_AVAILABLE" = "false" ]; then
        echo "Auth0 MCP Server is not available"
        echo "Run './scripts/check-dependencies.sh' for installation instructions"
        return 1
    fi

    if [ -z "$AUTH0_DOMAIN" ] || [ -z "$AUTH0_CLIENT_ID" ] || [ -z "$AUTH0_CLIENT_SECRET" ]; then
        echo "Error: No tenant loaded"
        echo "Use 'auth0_load <tenant>' first to load credentials"
        return 1
    fi

    if command -v npx > /dev/null 2>&1; then
        echo "Configuring MCP Server for tenant: $AUTH0_CUSTOMER"
        npx @auth0/auth0-mcp-server init \
            --auth0-domain "$AUTH0_DOMAIN" \
            --auth0-client-id "$AUTH0_CLIENT_ID" \
            --auth0-client-secret "$AUTH0_CLIENT_SECRET"
        echo "✓ MCP Server configured for: $AUTH0_CUSTOMER"
    else
        echo "Error: npx not found"
        echo "Install Node.js to use Auth0 MCP Server"
        return 1
    fi
}

# MCP Server: Switch to loaded tenant (logout + init)
auth0_mcp_switch() {
    if [ "$AUTH0_MCP_AVAILABLE" = "false" ]; then
        echo "Auth0 MCP Server is not available"
        echo "Run './scripts/check-dependencies.sh' for installation instructions"
        return 1
    fi

    if [ -z "$AUTH0_DOMAIN" ]; then
        echo "Error: No tenant loaded"
        echo "Use 'auth0_load <tenant>' first"
        return 1
    fi

    # Check if MCP Server has active session
    if command -v npx > /dev/null 2>&1; then
        if npx @auth0/auth0-mcp-server session > /dev/null 2>&1; then
            echo "Logging out of current MCP Server session..."
            npx @auth0/auth0-mcp-server logout
        fi
    fi

    # Initialize with new tenant
    auth0_mcp_init
}

# Show help for Auth0 helper functions
auth0_help() {
    cat <<'EOF'
Auth0 Helper Functions
======================

Credential Management:
  auth0_add <tenant>           Add new tenant credentials (interactive)
  auth0_load <tenant>          Load tenant credentials into environment
  auth0_unload                 Unload current tenant (clear env vars)
  auth0_remove <tenant>        Remove tenant credentials from keychain
  auth0_list                   List all stored tenants
  auth0_current                Show currently loaded tenant

Configuration & Deployment:
  auth0_generate_config [tenant] [file]  Generate config.json for Deploy CLI
  auth0_deploy [dir]           Deploy configuration to current tenant
  auth0_export [dir]           Export configuration from current tenant

Utilities:
  auth0_dashboard [tenant]     Open Auth0 dashboard in browser
  auth0_help                   Show this help message

MCP Server (optional):
  auth0_mcp_session            Show current MCP Server session
  auth0_mcp_init               Configure MCP Server with loaded tenant
  auth0_mcp_switch             Switch MCP Server to loaded tenant (logout + init)
  auth0_mcp_logout             Logout from MCP Server

Environment Variables (set by auth0_load):
  $AUTH0_CUSTOMER              Current tenant name
  $AUTH0_DOMAIN                Auth0 domain
  $AUTH0_CLIENT_ID             Client ID (M2M application)
  $AUTH0_CLIENT_SECRET         Client secret

Example Workflow:
  1. auth0_add my-dev-tenant        # Add credentials (first time)
  2. auth0_load my-dev-tenant       # Load credentials
  3. auth0_export                   # Export current config
  4. # Make changes to Auth0Tenant/
  5. auth0_deploy                   # Deploy changes
  6. auth0_dashboard                # Open dashboard to verify

Notes:
  - Credentials are stored securely in macOS Keychain
  - Environment variables persist in your current shell session
  - Auth0 Deploy CLI uses these environment variables automatically
  - Always use 'auth0_load' before running deploy/export commands
  - Compatible with both bash and zsh
EOF
}

# Auto-display message on source
echo "✓ Auth0 helper functions loaded. Type 'auth0_help' for usage."
