# Auth0 Development Assistant - Claude Skill

A comprehensive Claude Code skill that enables Auth0 developers to leverage Claude as a coding assistant for Auth0 tenant management, configuration deployment, and secure credential handling.

## Overview

This skill teaches Claude how to:
- Use **Auth0 CLI** for tenant management operations
- Use **Auth0 Deploy CLI** for configuration-as-code deployment
- Integrate with **Auth0 MCP Server** for Auth0 operations
- Manage credentials securely using **macOS Keychain**
- Create Auth0 resources (Actions, Rules, Hooks, etc.) with proper file structure
- Follow Auth0 best practices and conventions

## Installation

### Prerequisites

1. **Auth0 CLI**
   ```bash
   brew tap auth0/auth0-cli && brew install auth0
   ```

2. **Auth0 Deploy CLI**
   ```bash
   npm install -g auth0-deploy-cli
   ```

3. **Auth0 MCP Server** (optional)
   Follow the installation instructions from the Auth0 MCP Server repository.

### Skill Installation

1. Clone or download this repository
2. Ensure scripts are executable:
   ```bash
   chmod +x scripts/*.sh
   ```

3. Add the skill to Claude Code (see Usage section)

## Project Structure

```
ClaudeSkill_Auth0CLIs/
├── skill.md                 # Main skill instructions for Claude
├── scripts/                 # macOS Keychain helper scripts
│   ├── store-tenant.sh     # Store tenant credentials
│   ├── get-tenant.sh       # Retrieve tenant credentials
│   ├── list-tenants.sh     # List all stored tenants
│   ├── remove-tenant.sh    # Remove tenant credentials
│   └── create-config.sh    # Generate config.json from keychain
├── Auth0Tenant/            # Your Auth0 configuration files
└── README.md               # This file
```

## Usage

### Loading the Skill in Claude Code

Reference this skill in your Claude Code conversations when working with Auth0:

```bash
# In Claude Code, reference the skill
@skill /path/to/ClaudeSkill_Auth0CLIs/skill.md
```

Or configure it as a persistent skill in your Claude Code settings.

### Managing Tenant Credentials

**Store tenant credentials:**
```bash
./scripts/store-tenant.sh my-dev-tenant dev-example.us.auth0.com client-id client-secret
```

**List all stored tenants:**
```bash
./scripts/list-tenants.sh
```

**Retrieve tenant credentials:**
```bash
./scripts/get-tenant.sh my-dev-tenant
```

**Create config.json for Deploy CLI:**
```bash
./scripts/create-config.sh my-dev-tenant
```

**Remove tenant credentials:**
```bash
./scripts/remove-tenant.sh my-dev-tenant
```

### Example Interactions with Claude

Once the skill is loaded, you can ask Claude:

**Create Auth0 resources:**
```
"Create an action that checks whether a user has enrolled for MFA and if not start the MFA enrollment flow"
```

**Deploy configurations:**
```
"Deploy my local changes to my dev tenant"
```

**Setup projects:**
```
"Set up a new Auth0 project with proper directory structure"
```

**Export configurations:**
```
"Export my current tenant configuration to the Auth0Tenant directory"
```

**Manage credentials:**
```
"Store credentials for my production tenant"
"List all my configured Auth0 tenants"
```

## Auth0 Configuration Structure

The `Auth0Tenant/` directory should follow the Auth0 Deploy CLI structure:

```
Auth0Tenant/
├── actions/
│   └── <action-name>/
│       ├── code.js
│       └── action.json
├── rules/
│   └── <rule-name>.js
├── pages/
│   ├── login.html
│   └── password_reset.html
├── databases/
│   └── <connection-name>/
│       ├── database.json
│       ├── login.js
│       └── create.js
├── clients/
│   └── <client-name>.json
├── resource-servers/
│   └── <api-identifier>.json
└── tenant.yaml
```

## Security Best Practices

1. **Never commit credentials** - `config.json` is in `.gitignore`
2. **Use keychain for local development** - All credentials stored securely in macOS Keychain
3. **Use environment variables in CI/CD** - Don't use keychain in automated environments
4. **Review configurations before deploying** - Always check what will be deployed
5. **Use separate tenants for dev/staging/prod** - Don't test in production

## Troubleshooting

### Keychain Access Issues

If you get keychain access errors:
1. Open "Keychain Access" app on macOS
2. Look for entries with service name `auth0-tenant-*`
3. Grant access to Terminal/your shell when prompted

### Script Permission Issues

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Auth0 API Permissions

Ensure your Auth0 Application (Machine-to-Machine) has Management API permissions with the following scopes:
- `read:clients`, `create:clients`, `update:clients`
- `read:resource_servers`, `create:resource_servers`, `update:resource_servers`
- `read:actions`, `create:actions`, `update:actions`
- `read:rules`, `create:rules`, `update:rules`
- And other scopes as needed for your use case

## Resources

- [Auth0 CLI Documentation](https://auth0.com/docs/cli)
- [Auth0 Deploy CLI GitHub](https://github.com/auth0/auth0-deploy-cli)
- [Auth0 Actions Documentation](https://auth0.com/docs/customize/actions)
- [Auth0 Management API](https://auth0.com/docs/api/management/v2)

## Contributing

This is a personal skill repository. Feel free to fork and customize for your own needs.

## License

MIT License - Feel free to use and modify as needed.
