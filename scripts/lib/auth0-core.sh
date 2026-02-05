#!/bin/sh

# Core Auth0 Keychain Functions (POSIX-compliant for bash/zsh compatibility)
# This library is sourced by both standalone scripts and auth0-helpers.sh

# Get the directory where this script lives
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Store credentials in keychain
_auth0_store_credentials() {
    local tenant="$1"
    local domain="$2"
    local client_id="$3"
    local client_secret="$4"

    # Validate inputs
    if [ -z "$tenant" ] || [ -z "$domain" ] || [ -z "$client_id" ] || [ -z "$client_secret" ]; then
        echo "Error: All parameters required" >&2
        return 1
    fi

    # Store in keychain
    security add-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_domain" \
        -w "${domain}" \
        -U 2>/dev/null || {
        echo "Error: Failed to store domain in keychain" >&2
        return 1
    }

    security add-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_client_id" \
        -w "${client_id}" \
        -U 2>/dev/null || {
        echo "Error: Failed to store client ID in keychain" >&2
        return 1
    }

    security add-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_client_secret" \
        -w "${client_secret}" \
        -U 2>/dev/null || {
        echo "Error: Failed to store client secret in keychain" >&2
        return 1
    }

    return 0
}

# Retrieve credentials from keychain
_auth0_get_credentials() {
    local tenant="$1"

    if [ -z "$tenant" ]; then
        echo "Error: Tenant name required" >&2
        return 1
    fi

    local domain client_id client_secret

    domain=$(security find-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_domain" \
        -w 2>/dev/null) || {
        echo "Error: Tenant '${tenant}' not found in keychain" >&2
        return 1
    }

    client_id=$(security find-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_client_id" \
        -w 2>/dev/null) || {
        echo "Error: Client ID not found" >&2
        return 1
    }

    client_secret=$(security find-generic-password \
        -a "$USER" \
        -s "auth0_${tenant}_client_secret" \
        -w 2>/dev/null) || {
        echo "Error: Client secret not found" >&2
        return 1
    }

    # Output in parseable format
    echo "DOMAIN=$domain"
    echo "CLIENT_ID=$client_id"
    echo "CLIENT_SECRET=$client_secret"
}

# List all stored tenants
_auth0_list_tenants() {
    local tenants current_marker

    tenants=$(security dump-keychain 2>/dev/null | \
        grep '"svce"<blob>="auth0_.*_domain"' | \
        sed -E 's/.*"svce"<blob>="auth0_(.*)_domain".*/\1/' | \
        sort -u)

    if [ -z "$tenants" ]; then
        return 0
    fi

    echo "$tenants" | while IFS= read -r tenant; do
        if [ -n "$tenant" ]; then
            local domain
            domain=$(security find-generic-password \
                -a "$USER" \
                -s "auth0_${tenant}_domain" \
                -w 2>/dev/null || echo "unknown")

            if [ "$tenant" = "$AUTH0_CUSTOMER" ]; then
                echo "${tenant}|${domain}|CURRENT"
            else
                echo "${tenant}|${domain}|"
            fi
        fi
    done
}

# Remove credentials from keychain
_auth0_remove_credentials() {
    local tenant="$1"

    if [ -z "$tenant" ]; then
        echo "Error: Tenant name required" >&2
        return 1
    fi

    security delete-generic-password -a "$USER" -s "auth0_${tenant}_domain" 2>/dev/null
    security delete-generic-password -a "$USER" -s "auth0_${tenant}_client_id" 2>/dev/null
    security delete-generic-password -a "$USER" -s "auth0_${tenant}_client_secret" 2>/dev/null

    return 0
}

# Generate dashboard URL
_auth0_dashboard_url() {
    local domain="$1"

    if [ -z "$domain" ]; then
        echo "Error: Domain required" >&2
        return 1
    fi

    # Extract tenant name (first part before first dot)
    local tenant_name
    tenant_name=$(echo "$domain" | cut -d'.' -f1)

    # Count dots to determine cloud type
    local dot_count
    dot_count=$(echo "$domain" | tr -cd '.' | wc -c | xargs)

    if [ "$dot_count" -gt 1 ]; then
        # Private cloud
        local private_cloud_domain
        private_cloud_domain=$(echo "$domain" | cut -d'.' -f2-)
        echo "https://manage.${private_cloud_domain}/dashboard/pi/${tenant_name}/"
    else
        # Public cloud
        echo "https://manage.auth0.com/dashboard/us/${tenant_name}/"
    fi
}

# Prompt for input (works in both bash and zsh)
_auth0_prompt() {
    local prompt="$1"
    local varname="$2"
    local silent="$3"

    printf "%s" "$prompt"

    if [ "$silent" = "silent" ]; then
        # Silent input for passwords
        stty -echo
        read -r "$varname"
        stty echo
        printf "\n"
    else
        read -r "$varname"
    fi
}
