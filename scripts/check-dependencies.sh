#!/bin/sh

# Check for required Auth0 CLI tools
# Usage: ./check-dependencies.sh [--quiet]

QUIET=false
if [ "$1" = "--quiet" ]; then
    QUIET=true
fi

# Track overall status
ALL_OK=true

# Color codes for output
if [ "$QUIET" = false ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
fi

# Function to check if command exists
check_command() {
    local cmd="$1"
    local required="$2"
    local install_hint="$3"

    if command -v "$cmd" > /dev/null 2>&1; then
        if [ "$QUIET" = false ]; then
            printf "${GREEN}✓${NC} %-20s %s\n" "$cmd" "$(command -v "$cmd")"
        fi
        return 0
    else
        if [ "$required" = "required" ]; then
            ALL_OK=false
            if [ "$QUIET" = false ]; then
                printf "${RED}✗${NC} %-20s %s\n" "$cmd" "NOT FOUND (required)"
                echo "  Install: $install_hint"
            fi
            return 1
        else
            if [ "$QUIET" = false ]; then
                printf "${YELLOW}⚠${NC} %-20s %s\n" "$cmd" "NOT FOUND (optional)"
                echo "  Install: $install_hint"
            fi
            return 2
        fi
    fi
}

if [ "$QUIET" = false ]; then
    echo "Checking Auth0 CLI dependencies..."
    echo ""
fi

# Required tools
check_command "auth0" "required" "brew tap auth0/auth0-cli && brew install auth0"
AUTH0_CLI_STATUS=$?

check_command "a0deploy" "required" "npm install -g auth0-deploy-cli"
A0DEPLOY_STATUS=$?

# Optional tools
check_command "npx" "optional" "Install Node.js from https://nodejs.org"
NPX_STATUS=$?

# Check for MCP Server if npx is available
AUTH0_MCP_AVAILABLE=false
if [ $NPX_STATUS -eq 0 ]; then
    if npx -y @auth0/auth0-mcp-server --help > /dev/null 2>&1; then
        AUTH0_MCP_AVAILABLE=true
        if [ "$QUIET" = false ]; then
            printf "${GREEN}✓${NC} %-20s %s\n" "auth0-mcp-server" "available via npx"
        fi
    else
        if [ "$QUIET" = false ]; then
            printf "${YELLOW}⚠${NC} %-20s %s\n" "auth0-mcp-server" "NOT FOUND (optional)"
            echo "  Install: npm install -g @auth0/auth0-mcp-server"
        fi
    fi
fi

if [ "$QUIET" = false ]; then
    echo ""
fi

# Export status for other scripts to use
if [ "$AUTH0_MCP_AVAILABLE" = true ]; then
    export AUTH0_MCP_AVAILABLE=true
    if [ "$QUIET" = false ]; then
        echo "Environment: AUTH0_MCP_AVAILABLE=true"
    fi
else
    export AUTH0_MCP_AVAILABLE=false
    if [ "$QUIET" = false ]; then
        echo "Environment: AUTH0_MCP_AVAILABLE=false (MCP Server commands will be skipped)"
    fi
fi

if [ "$QUIET" = false ]; then
    echo ""
fi

# Exit with appropriate status
if [ "$ALL_OK" = false ]; then
    if [ "$QUIET" = false ]; then
        printf "${RED}✗ Missing required dependencies${NC}\n"
        echo "Please install the missing tools listed above."
    fi
    exit 1
else
    if [ "$QUIET" = false ]; then
        printf "${GREEN}✓ All required dependencies are installed${NC}\n"
    fi
    exit 0
fi
