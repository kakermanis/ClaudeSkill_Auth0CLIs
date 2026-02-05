# Auth0 Project - [Your Project Name]

An Auth0 tenant configuration project with Claude Code integration for AI-assisted development.

## Quick Start

### 1. Check Dependencies
```bash
./scripts/check-dependencies.sh
```

Installs required tools if missing:
- **Auth0 CLI**: `brew tap auth0/auth0-cli && brew install auth0`
- **Auth0 Deploy CLI**: `npm install -g auth0-deploy-cli`
- **Auth0 MCP Server** (optional): `npm install -g @auth0/auth0-mcp-server`

### 2. Add Your Tenant Credentials

```bash
# Interactive mode (recommended)
./scripts/store-tenant.sh my-tenant

# With MCP Server integration for private cloud
./scripts/store-tenant.sh my-tenant --with-mcp
```

### 3. Load the Auth0 Skill in Claude Code

When working with Claude Code:

```
@skill ./skill.md
```

This teaches Claude about your Auth0 environment and available commands.

## Using Claude Code for Auth0 Development

Once the skill is loaded, you can ask Claude to:

- **Create Auth0 resources**: "Create an action that checks MFA enrollment"
- **Deploy configurations**: "Deploy my changes to the dev tenant"
- **Export configurations**: "Export my tenant config to Auth0Tenant/"
- **Manage tenants**: "List all my configured tenants"

Claude will use the scripts in `./scripts/` to manage your Auth0 tenant securely via macOS Keychain.

## Project Structure

```
.
├── skill.md                    # Claude Code skill (teaches Claude about Auth0)
├── scripts/                    # Keychain & deployment helper scripts
│   ├── check-dependencies.sh  # Verify required tools
│   ├── store-tenant.sh        # Store tenant credentials
│   ├── load-tenant.sh         # Load credentials (use with eval)
│   ├── list-tenants.sh        # List all tenants
│   ├── current-tenant.sh      # Show loaded tenant
│   ├── dashboard.sh           # Open Auth0 dashboard
│   └── auth0-helpers.sh       # Sourceable shell functions
├── Auth0Tenant/               # Your Auth0 configuration (managed by Deploy CLI)
│   ├── actions/
│   ├── rules/
│   ├── pages/
│   ├── clients/
│   └── resource-servers/
└── .claude/                   # Claude Code project settings
    └── settings.json          # Auto-loads skill reminder on session start
```

## Workflow Examples

### For Interactive Development (Terminal)

```bash
# Source helper functions (add to ~/.zshrc for persistence)
source ./scripts/auth0-helpers.sh

# Load tenant
auth0_load my-dev-tenant

# Export configuration
auth0_export

# Make changes to Auth0Tenant/...

# Deploy changes
auth0_deploy

# Open dashboard to verify
auth0_dashboard
```

### With Claude Code

Claude handles the persistent shell for you automatically! Just:

1. Load the skill: `@skill ./skill.md`
2. Ask Claude to perform Auth0 operations
3. Claude uses the scripts behind the scenes

## Security

- ✅ Credentials stored in macOS Keychain (not in files)
- ✅ `config.json` is gitignored
- ✅ No credentials in environment history
- ✅ Multi-tenant support with easy switching

## Support

For issues or questions about:
- **The Auth0 skill**: See [skill.md](skill.md) documentation
- **Helper scripts**: Run `auth0_help` after sourcing auth0-helpers.sh
- **Auth0 Deploy CLI**: https://github.com/auth0/auth0-deploy-cli
- **Auth0 CLI**: https://auth0.com/docs/cli

---

🤖 This project uses [Claude Code](https://claude.ai/code) with the Auth0 Development Assistant skill for AI-powered Auth0 tenant management.
