# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code skill** that teaches Claude how to assist Auth0 developers with tenant management, configuration deployment, and secure credential handling. The skill integrates with Auth0 CLI, Auth0 Deploy CLI, and macOS Keychain.

**Key concept**: This repository IS the skill itself - [skill.md](skill.md) contains the complete instructions that get loaded into Claude Code sessions to enable Auth0 development assistance.

## Architecture

### 1. Skill System

- [skill.md](skill.md) - The core skill instructions loaded by Claude Code
- When users reference this skill (`@skill /path/to/skill.md`), Claude gains Auth0-specific knowledge
- The skill teaches Claude to create Auth0 resources, manage deployments, and handle credentials securely

### 2. Script Architecture (scripts/)

All scripts follow a **shared core library pattern**:

```
scripts/
├── lib/
│   └── auth0-core.sh          # Core library with keychain functions
├── *.sh                        # Standalone executables (source core library)
└── auth0-helpers.sh            # Sourceable functions for interactive shells
```

**Keychain Pattern**:
- Service names: `auth0_${tenant}_domain`, `auth0_${tenant}_client_id`, `auth0_${tenant}_client_secret`
- Account: Current macOS user (`$USER`)
- Each tenant has 3 keychain entries

**Environment Variables** (set when tenant is loaded):
- `AUTH0_CUSTOMER` - Currently loaded tenant name
- `AUTH0_DOMAIN` - Auth0 domain
- `AUTH0_CLIENT_ID` - Client ID
- `AUTH0_CLIENT_SECRET` - Client secret

Auth0 Deploy CLI automatically reads these environment variables, eliminating the need for config.json.

### 3. Configuration Structure

Default directory: `Auth0Tenant/` (follows Auth0 Deploy CLI conventions)

```
Auth0Tenant/
├── actions/                    # Auth0 Actions (Node.js)
│   └── <name>/
│       ├── code.js
│       └── action.json
├── rules/                      # Auth0 Rules (deprecated but supported)
├── pages/                      # Hosted pages (login, MFA, etc.)
├── clients/                    # Application configurations
├── resource-servers/           # API configurations
├── databases/                  # Custom database scripts
└── tenant.yaml                 # Tenant settings
```

## Essential Commands

### Script Usage (Two Patterns)

**Pattern 1: Standalone Scripts** (for automation/CI-CD)
```bash
# Store credentials (interactive prompt)
./scripts/store-tenant.sh dev-tenant

# Load credentials (MUST use eval)
eval $(./scripts/load-tenant.sh dev-tenant)

# List all tenants
./scripts/list-tenants.sh

# Check current tenant
./scripts/current-tenant.sh

# Open Auth0 dashboard
./scripts/dashboard.sh

# Generate config.json (optional)
./scripts/create-config.sh [tenant-name] [output-file]
```

**Pattern 2: Sourceable Functions** (for interactive development)
```bash
# One-time setup (add to ~/.zshrc or ~/.bashrc)
source /path/to/scripts/auth0-helpers.sh

# Daily usage
auth0_load dev-tenant           # Load credentials
auth0_list                      # List tenants
auth0_current                   # Show current tenant
auth0_deploy                    # Deploy to Auth0
auth0_export                    # Export from Auth0
auth0_dashboard                 # Open dashboard
auth0_help                      # Show all commands
```

### Auth0 Deploy CLI (Primary Deployment Tool)

**With environment variables** (preferred):
```bash
# After loading tenant
a0deploy import -i Auth0Tenant/              # Deploy
a0deploy export -f yaml -o Auth0Tenant/      # Export
```

**With config.json** (alternative):
```bash
a0deploy import -c config.json -i Auth0Tenant/
```

### Common Development Workflow

```bash
# 1. Load tenant credentials
eval $(./scripts/load-tenant.sh dev-tenant)

# 2. Export current configuration
a0deploy export -f yaml -o Auth0Tenant/

# 3. Make changes to Auth0Tenant/ files

# 4. Deploy changes
a0deploy import -i Auth0Tenant/

# 5. Verify in dashboard
./scripts/dashboard.sh
```

## Key Conventions for Claude

When assisting users with Auth0 development:

### Resource Creation
1. **Always use `Auth0Tenant/` as the default directory name** (not `tenant/`)
2. **Follow Auth0 Deploy CLI structure**:
   - Actions: `actions/<name>/code.js` + `actions/<name>/action.json`
   - Rules: `rules/<name>.js`
   - Pages: `pages/login.html`, `pages/password_reset.html`, etc.
3. **Use Node.js 18 runtime** for Actions (latest supported)
4. **Include error handling** in all code

### Credential Management
1. **Check if tenant is loaded first**: Look for `$AUTH0_CUSTOMER` or suggest `./scripts/current-tenant.sh`
2. **If not loaded**: Guide user to run `eval $(./scripts/load-tenant.sh <tenant>)`
3. **Never suggest hardcoding credentials** in files

### Deployment
1. **Prefer environment variables over config.json**
2. **Standard deployment flow**:
   ```bash
   eval $(./scripts/load-tenant.sh <tenant>)
   a0deploy import -i Auth0Tenant/
   ```
3. **Only suggest config.json** for CI/CD scenarios

### Multi-Tenant Workflows
1. Use `./scripts/list-tenants.sh` to show available tenants
2. `[CURRENT]` marker indicates loaded tenant
3. Switch tenants: `eval $(./scripts/load-tenant.sh other-tenant)`

## Security Best Practices

- **Never commit**: `config.json`, `config.*.json`, `.env` files (already in [.gitignore](.gitignore))
- **Credentials storage**: Always use macOS Keychain via helper scripts
- **Environment variables**: Preferred for deployment (keeps credentials in keychain)
- **CI/CD**: Use platform-specific secret management (GitHub Secrets, etc.), not keychain

## Testing & Validation

No automated tests exist in this repository. When modifying scripts:

1. **Test script execution permissions**: `chmod +x scripts/*.sh`
2. **Verify keychain access**: Check System Preferences > Privacy & Security
3. **Test with actual tenant**: Store credentials and test full workflow
4. **Verify shell compatibility**: Scripts are POSIX-compliant (bash/zsh compatible)

## Important Files to Understand

- [skill.md](skill.md) - Complete skill instructions (the "brain" of the skill)
- [README.md](README.md) - User-facing documentation
- [scripts/lib/auth0-core.sh](scripts/lib/auth0-core.sh) - Core keychain functionality
- [scripts/auth0-helpers.sh](scripts/auth0-helpers.sh) - Interactive shell functions
- [CHANGES.md](CHANGES.md) - Recent architectural changes and rationale

## When to Update This Skill

Update [skill.md](skill.md) when:
- Auth0 CLI commands change
- Auth0 Deploy CLI conventions evolve
- New Auth0 features are added (Actions triggers, etc.)
- Script workflow patterns change
- New helper scripts are added

The skill should remain focused on teaching Claude about Auth0-specific patterns, not general development practices.
