# Auth0 Keychain Scripts

This directory contains helper scripts for managing Auth0 tenant credentials securely using macOS Keychain.

## Two Approaches

### 1. Sourceable Functions (Recommended for Interactive Use)

**File:** `auth0-helpers.sh`

Source this file in your shell for persistent environment variables:

```bash
# Add to ~/.zshrc or ~/.bashrc
source /path/to/scripts/auth0-helpers.sh

# Then use functions directly
auth0_add my-dev-tenant
auth0_load my-dev-tenant
auth0_deploy
```

**Available Functions:**
- `auth0_add <tenant>` - Add new tenant credentials (interactive)
- `auth0_load <tenant>` - Load tenant credentials into environment
- `auth0_unload` - Unload current tenant (clear env vars)
- `auth0_remove <tenant>` - Remove tenant credentials from keychain
- `auth0_list` - List all stored tenants
- `auth0_current` - Show currently loaded tenant
- `auth0_generate_config [tenant] [file]` - Generate config.json
- `auth0_deploy [dir]` - Deploy to current tenant
- `auth0_export [dir]` - Export from current tenant
- `auth0_dashboard [tenant]` - Open Auth0 dashboard
- `auth0_help` - Show help

### 2. Standalone Scripts (For Automation/Scripts)

Individual scripts that can be called directly:

```bash
# Store credentials
./store-tenant.sh my-dev-tenant

# Load credentials (requires eval)
eval $(./load-tenant.sh my-dev-tenant)

# List tenants
./list-tenants.sh

# Show current
./current-tenant.sh

# Create config.json
./create-config.sh

# Open dashboard
./dashboard.sh

# Remove tenant
./remove-tenant.sh my-dev-tenant
```

## Keychain Storage Pattern

Credentials are stored in macOS Keychain with this pattern:
- Service: `auth0_${tenant}_domain`
- Service: `auth0_${tenant}_client_id`
- Service: `auth0_${tenant}_client_secret`
- Account: `$USER` (your macOS username)

## Environment Variables

When a tenant is loaded, these variables are set:
- `AUTH0_CUSTOMER` - Tenant name
- `AUTH0_DOMAIN` - Auth0 domain (e.g., `tenant.auth0.com`)
- `AUTH0_CLIENT_ID` - Machine-to-Machine application client ID
- `AUTH0_CLIENT_SECRET` - Client secret

Auth0 Deploy CLI automatically uses these environment variables, so you don't need to pass them explicitly.

## Workflow Comparison

### Using Sourceable Functions

```bash
# One-time setup: add to ~/.zshrc
source /path/to/scripts/auth0-helpers.sh

# Daily workflow
auth0_load dev-tenant
auth0_export                    # Export config
# Make changes
auth0_deploy                    # Deploy changes
auth0_dashboard                 # Open dashboard
```

### Using Standalone Scripts

```bash
# Daily workflow
eval $(./scripts/load-tenant.sh dev-tenant)
a0deploy export -f yaml -o Auth0Tenant/
# Make changes
a0deploy import -i Auth0Tenant/
./scripts/dashboard.sh
```

## Examples

### Add a New Tenant (Interactive)

```bash
./store-tenant.sh my-dev-tenant
# Enter domain: dev-tenant.us.auth0.com
# Enter client ID: abc123...
# Enter client secret: ***
```

### Add a New Tenant (Non-Interactive)

```bash
./store-tenant.sh my-dev-tenant dev-tenant.us.auth0.com abc123 secret456
```

### Load and Deploy

```bash
# Load tenant
eval $(./load-tenant.sh my-dev-tenant)

# Deploy without config.json (uses env vars)
a0deploy import -i Auth0Tenant/

# Export without config.json (uses env vars)
a0deploy export -f yaml -o Auth0Tenant/
```

### Generate config.json for CI/CD

```bash
# From loaded tenant
eval $(./load-tenant.sh prod-tenant)
./create-config.sh config.prod.json

# Or specify tenant
./create-config.sh prod-tenant config.prod.json
```

### Switch Between Tenants

```bash
# List available tenants
./list-tenants.sh

# Load dev tenant
eval $(./load-tenant.sh dev-tenant)
./current-tenant.sh    # Shows: dev-tenant

# Switch to prod tenant
eval $(./load-tenant.sh prod-tenant)
./current-tenant.sh    # Shows: prod-tenant
```

### Open Dashboard

```bash
# For currently loaded tenant
./dashboard.sh

# For specific tenant
./dashboard.sh prod-tenant
```

## Script Details

### store-tenant.sh
Stores tenant credentials in keychain. Supports interactive and non-interactive modes.

### load-tenant.sh
Loads tenant credentials and exports environment variables. Must be used with `eval`.

### list-tenants.sh
Lists all stored tenants with their domains. Highlights currently loaded tenant.

### current-tenant.sh
Shows which tenant is currently loaded and displays environment variables.

### create-config.sh
Generates config.json for Auth0 Deploy CLI. Can use loaded tenant or specify one.

### dashboard.sh
Opens Auth0 dashboard in browser. Supports public cloud and private cloud tenants.

### remove-tenant.sh
Removes tenant credentials from keychain.

### auth0-helpers.sh
All-in-one file with all functions for sourcing into shell.

## Security Notes

- Credentials are stored securely in macOS Keychain
- You may be prompted for keychain access when first using scripts
- Environment variables persist only in current shell session
- Always ensure config.json is in .gitignore
- Never commit credentials to version control

## Troubleshooting

### "Tenant not found in keychain"
Make sure you've stored the tenant first: `./store-tenant.sh <tenant-name>`

### "No tenant currently loaded"
Load a tenant: `eval $(./load-tenant.sh <tenant-name>)`

### Scripts not executable
Run: `chmod +x scripts/*.sh`

### Keychain access denied
- Open Keychain Access app
- Find `auth0_*` entries
- Grant access to Terminal/your shell when prompted

## Migration from Old Pattern

If you have tenants stored with the old pattern (`auth0-tenant-*`), you'll need to re-add them:

```bash
# Remove old entries (if needed)
security delete-generic-password -a "tenant-name" -s "auth0-tenant-domain"

# Add with new pattern
./store-tenant.sh tenant-name
```
