# Auth0 Development Assistant

This skill enables Claude to assist Auth0 developers with comprehensive tenant management, configuration deployment, and secure credential handling using the Auth0 CLI, Auth0 Deploy CLI, Auth0 MCP Server, and macOS Keychain.

## Quick Reference: Script Commands

**Credential Management:**
```bash
./scripts/store-tenant.sh <tenant>              # Store credentials (interactive)
eval $(./scripts/load-tenant.sh <tenant>)       # Load credentials (sets env vars)
./scripts/list-tenants.sh                       # List all tenants
./scripts/current-tenant.sh                     # Show loaded tenant
./scripts/dashboard.sh                          # Open Auth0 dashboard
./scripts/remove-tenant.sh <tenant>             # Remove credentials
```

**Deployment:**
```bash
# After loading tenant with eval $(./scripts/load-tenant.sh <tenant>)
a0deploy import -i Auth0Tenant/                 # Deploy (uses env vars)
a0deploy export -f yaml -o Auth0Tenant/         # Export (uses env vars)
./scripts/create-config.sh                      # Generate config.json (optional)
```

**Alternative: Sourceable Functions**
```bash
source scripts/auth0-helpers.sh                 # Load functions
auth0_load <tenant>                             # Load tenant
auth0_deploy                                    # Deploy
auth0_export                                    # Export
auth0_help                                      # Show all commands
```

## Overview

This skill provides Claude with knowledge and tools to:
- Manage Auth0 tenants and credentials securely using macOS Keychain
- Create Auth0 resources (Actions, Rules, Hooks, etc.) with proper file structure
- Deploy configurations using Auth0 Deploy CLI or Auth0 MCP Server
- Execute Auth0 CLI commands for tenant management
- Follow Auth0 best practices and project conventions
- Use environment variables for deployment (no config.json needed)

## Core Components

### 1. Auth0 CLI
The primary command-line tool for Auth0 management operations.

**Installation:**
```bash
brew tap auth0/auth0-cli && brew install auth0
```

**Common Commands:**
- `auth0 login` - Authenticate with Auth0
- `auth0 tenants list` - List available tenants
- `auth0 apps list` - List applications
- `auth0 apis list` - List APIs
- `auth0 users list` - List users
- `auth0 logs tail` - Stream tenant logs

### 2. Auth0 Deploy CLI
Tool for deploying Auth0 tenant configurations as code.

**Installation:**
```bash
npm install -g auth0-deploy-cli
```

**Key Features:**
- Import/export tenant configurations
- Deploy directory-based configurations
- Support for Actions, Rules, Pages, Resource Servers, Clients, etc.

**Typical Directory Structure:**
```
tenant/
├── actions/
│   └── <action-name>/
│       ├── code.js
│       └── action.json
├── rules/
│   └── <rule-name>.js
├── pages/
│   ├── login.html
│   └── password_reset.html
├── resource-servers/
│   └── <api-identifier>.json
├── clients/
│   └── <client-name>.json
├── databases/
│   └── <database-name>/
│       ├── database.json
│       ├── create.js
│       ├── login.js
│       └── delete.js
└── tenant.yaml
```

**Deployment Command:**
```bash
a0deploy import -c config.json -i tenant/
```

**Export Command:**
```bash
a0deploy export -c config.json -f yaml -o tenant/
```

### 3. Auth0 MCP Server
Model Context Protocol server for Auth0 operations (if installed).

**Common Operations via MCP:**
- Reading tenant configurations
- Updating configurations
- Deploying changes
- Querying tenant state

### 4. macOS Keychain Integration
Secure storage for Auth0 tenant credentials using macOS Keychain.

**Helper Scripts Location:** `./scripts/`

**Script Architecture:**
- `lib/auth0-core.sh` - Core library with shared keychain functions
- Standalone scripts - Individual executables that source the core library
- `auth0-helpers.sh` - Sourceable functions for interactive shell use

**Keychain Storage Pattern:** `auth0_${tenant}_domain`, `auth0_${tenant}_client_id`, `auth0_${tenant}_client_secret`

**Stored Credentials per Tenant:**
- Domain (e.g., `dev-example.us.auth0.com`)
- Client ID
- Client Secret

**Environment Variables (when tenant is loaded):**
- `AUTH0_CUSTOMER` - Current tenant name
- `AUTH0_DOMAIN` - Auth0 domain
- `AUTH0_CLIENT_ID` - Client ID
- `AUTH0_CLIENT_SECRET` - Client secret

**Important:** Auth0 Deploy CLI automatically uses these environment variables, so config.json is optional when a tenant is loaded.

## Workflow Instructions

### Credential Management

There are **two approaches** for managing credentials:

#### Approach 1: Standalone Scripts (Recommended for automation/CI-CD)

1. **Store New Tenant Credentials:**
   ```bash
   # Interactive mode (prompts for credentials)
   ./scripts/store-tenant.sh dev-tenant

   # Non-interactive mode
   ./scripts/store-tenant.sh dev-tenant dev.us.auth0.com abc123 secret456
   ```

2. **Load Tenant Credentials (exports environment variables):**
   ```bash
   # IMPORTANT: Must use eval to set environment variables
   eval $(./scripts/load-tenant.sh dev-tenant)

   # This sets: $AUTH0_CUSTOMER, $AUTH0_DOMAIN, $AUTH0_CLIENT_ID, $AUTH0_CLIENT_SECRET
   ```

3. **List Available Tenants:**
   ```bash
   ./scripts/list-tenants.sh
   # Shows [CURRENT] marker for loaded tenant
   ```

4. **Show Current Tenant:**
   ```bash
   ./scripts/current-tenant.sh
   # Displays loaded tenant and environment variables
   ```

5. **Open Auth0 Dashboard:**
   ```bash
   ./scripts/dashboard.sh              # Opens dashboard for loaded tenant
   ./scripts/dashboard.sh dev-tenant   # Opens dashboard for specific tenant
   ```

6. **Generate config.json:**
   ```bash
   ./scripts/create-config.sh                    # Uses loaded tenant
   ./scripts/create-config.sh dev-tenant         # Specific tenant
   ./scripts/create-config.sh dev-tenant config.dev.json
   ```

7. **Remove Tenant Credentials:**
   ```bash
   ./scripts/remove-tenant.sh dev-tenant
   ```

#### Approach 2: Sourceable Functions (Recommended for interactive development)

Users can source `auth0-helpers.sh` in their shell for convenient functions:

```bash
# Add to ~/.zshrc or ~/.bashrc (one-time setup)
source /path/to/scripts/auth0-helpers.sh
```

Then use functions directly:

```bash
# Add new tenant (interactive)
auth0_add dev-tenant

# Load tenant (sets environment variables)
auth0_load dev-tenant

# List tenants
auth0_list

# Show current tenant
auth0_current

# Open dashboard
auth0_dashboard

# Generate config.json
auth0_generate_config

# Deploy to tenant
auth0_deploy

# Export from tenant
auth0_export

# Unload tenant
auth0_unload

# Remove tenant
auth0_remove dev-tenant

# Show help
auth0_help
```

**When to use each approach:**
- **Standalone scripts**: CI/CD pipelines, automation scripts, one-off commands
- **Sourceable functions**: Interactive development, rapid tenant switching

### Creating Auth0 Resources

When a user requests creation of Auth0 resources (e.g., "Create an action that checks MFA enrollment"):

1. **Determine Resource Type:** Actions, Rules, Hooks, Database Scripts, Pages, etc.

2. **Create Appropriate Directory Structure:**
   - For **Actions**: Create `actions/<action-name>/` with `code.js` and `action.json`
   - For **Rules**: Create `rules/<rule-name>.js`
   - For **Hooks**: Create `hooks/<hook-name>.js`
   - For **Database Scripts**: Create `databases/<connection-name>/` with script files

3. **Generate Boilerplate Code** based on the resource type and user requirements

4. **Follow Auth0 Conventions:**
   - Use proper Auth0 Node.js SDK patterns
   - Include error handling
   - Add comments for clarity
   - Follow Auth0 best practices for the specific resource type

**Example - Creating an MFA Enrollment Check Action:**

Create file: `actions/mfa-enrollment-check/code.js`
```javascript
/**
 * Handler that will be called during the execution of a PostLogin flow.
 *
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {PostLoginAPI} api - Interface whose methods can be used to change the behavior of the login.
 */
exports.onExecutePostLogin = async (event, api) => {
  // Check if user has enrolled in MFA
  const enrolledFactors = event.user.multifactor || [];

  if (enrolledFactors.length === 0) {
    // User has not enrolled in MFA, trigger enrollment
    api.multifactor.enable('any', {
      allowRememberBrowser: false
    });
  }
};
```

Create file: `actions/mfa-enrollment-check/action.json`
```json
{
  "name": "mfa-enrollment-check",
  "supported_triggers": [
    {
      "id": "post-login",
      "version": "v3"
    }
  ],
  "dependencies": [],
  "runtime": "node18",
  "status": "built",
  "secrets": [],
  "deployed": false
}
```

### Deploying Changes

When a user requests deployment (e.g., "deploy my local changes to my tenant"):

#### Recommended Workflow (Using Environment Variables)

1. **Load Tenant Credentials:**
   ```bash
   # Using standalone scripts
   eval $(./scripts/load-tenant.sh dev-tenant)

   # OR using functions (if sourced)
   auth0_load dev-tenant
   ```

2. **Deploy Using Auth0 Deploy CLI:**
   ```bash
   # Deploy CLI automatically uses environment variables
   a0deploy import -i Auth0Tenant/

   # OR using functions
   auth0_deploy Auth0Tenant/
   ```

3. **Export Configuration:**
   ```bash
   # Export using environment variables
   a0deploy export -f yaml -o Auth0Tenant/

   # OR using functions
   auth0_export Auth0Tenant/
   ```

**Benefits of this approach:**
- No config.json needed (uses environment variables)
- Credentials stay in keychain, not in files
- Easy to switch between tenants
- Works in both bash and zsh

#### Alternative: Using config.json

If config.json is needed (e.g., for CI/CD):

1. **Generate config.json:**
   ```bash
   ./scripts/create-config.sh dev-tenant config.json
   ```

2. **Deploy with config.json:**
   ```bash
   a0deploy import -c config.json -i Auth0Tenant/
   ```

**config.json Structure:**
```json
{
  "AUTH0_DOMAIN": "your-tenant.auth0.com",
  "AUTH0_CLIENT_ID": "your-client-id",
  "AUTH0_CLIENT_SECRET": "your-client-secret",
  "AUTH0_ALLOW_DELETE": false,
  "AUTH0_EXCLUDED_RULES": [],
  "AUTH0_EXCLUDED_CLIENTS": ["Auth0 Deploy CLI"],
  "AUTH0_EXPORT_IDENTIFIERS": false
}
```

**IMPORTANT:** Always ensure config.json is in .gitignore

#### Using Auth0 MCP Server (if available)

If Auth0 MCP Server is installed, use MCP tools to deploy configurations:
- Check available MCP tools first
- Use MCP's deployment commands

## Best Practices

1. **Security:**
   - Never hardcode credentials in files
   - Always use keychain for credential storage
   - Use environment variables for CI/CD
   - Exclude `config.json` from version control

2. **Project Structure:**
   - Keep Auth0 configurations in a dedicated directory (e.g., `tenant/`)
   - Use descriptive names for Actions, Rules, etc.
   - Maintain separate configurations for different environments (dev, staging, prod)

3. **Actions Development:**
   - Use Node.js 18 runtime (latest)
   - Test locally before deploying
   - Handle errors gracefully
   - Use secrets for sensitive values
   - Follow Auth0's Action best practices

4. **Deployment:**
   - Review changes before deploying
   - Use `AUTH0_ALLOW_DELETE: false` to prevent accidental deletions
   - Exclude system clients from deployment
   - Keep backups of configurations

5. **Version Control:**
   - Commit Auth0 configurations to git
   - Use `.gitignore` for `config.json` and secrets
   - Document custom configurations

## Common Workflows

### Complete Workflow: Using Standalone Scripts

```bash
# 1. Store tenant credentials (first time)
./scripts/store-tenant.sh dev-tenant dev.us.auth0.com abc123 secret456

# 2. Load tenant credentials
eval $(./scripts/load-tenant.sh dev-tenant)

# 3. Export existing configuration
a0deploy export -f yaml -o Auth0Tenant/

# 4. Make changes to Auth0Tenant/ directory
# (Claude can help create Actions, Rules, etc.)

# 5. Deploy changes
a0deploy import -i Auth0Tenant/

# 6. Open dashboard to verify
./scripts/dashboard.sh

# 7. Switch to different tenant
eval $(./scripts/load-tenant.sh prod-tenant)
./scripts/current-tenant.sh  # Verify switch
```

### Complete Workflow: Using Functions

```bash
# One-time setup: Add to ~/.zshrc or ~/.bashrc
source /path/to/scripts/auth0-helpers.sh

# Daily workflow
auth0_add dev-tenant              # First time only
auth0_load dev-tenant             # Load credentials
auth0_export                      # Export configuration
# Make changes...
auth0_deploy                      # Deploy changes
auth0_dashboard                   # Open dashboard

# Switch tenants
auth0_load prod-tenant
auth0_current                     # Verify switch
```

### Initialize New Auth0 Project

```bash
# 1. Create project structure
mkdir -p Auth0Tenant/{actions,rules,pages,clients,databases}

# 2. Store tenant credentials
./scripts/store-tenant.sh my-tenant

# 3. Load tenant and export existing configuration
eval $(./scripts/load-tenant.sh my-tenant)
a0deploy export -f yaml -o Auth0Tenant/

# 4. Initialize git repository
git init
cat >> .gitignore <<EOF
config.json
config.*.json
node_modules/
.env
EOF

git add .
git commit -m "Initial Auth0 configuration"
```

### Create and Deploy Action

```bash
# 1. Load tenant
eval $(./scripts/load-tenant.sh dev-tenant)

# 2. Create action files (Claude generates these)
mkdir -p Auth0Tenant/actions/my-action
# Create code.js and action.json

# 3. Deploy to tenant (uses environment variables)
a0deploy import -i Auth0Tenant/ --verbose

# 4. Verify in dashboard
./scripts/dashboard.sh
```

### Work with Multiple Tenants

```bash
# Using standalone scripts - load one at a time
eval $(./scripts/load-tenant.sh dev-tenant)
a0deploy export -f yaml -o Auth0Tenant-dev/

eval $(./scripts/load-tenant.sh staging-tenant)
a0deploy export -f yaml -o Auth0Tenant-staging/

# Using functions - easier switching
source scripts/auth0-helpers.sh
auth0_load dev-tenant
auth0_list                 # Shows [CURRENT] marker
auth0_current              # Display loaded tenant

auth0_load staging-tenant
auth0_current              # Shows new tenant
```

## Claude's Decision Making

When users request Auth0 operations, Claude should:

### For Credential Management:
1. **Check if tenant is loaded**: Use `./scripts/current-tenant.sh` or check if `$AUTH0_CUSTOMER` is set
2. **If not loaded**: Instruct user to load tenant with `eval $(./scripts/load-tenant.sh <tenant>)`
3. **If tenant not found**: Guide user to store credentials with `./scripts/store-tenant.sh`

### For Deployment:
1. **Prefer environment variables over config.json**: Guide users to load tenant first
2. **Example**:
   ```bash
   eval $(./scripts/load-tenant.sh dev-tenant)
   a0deploy import -i Auth0Tenant/
   ```
3. **Only suggest config.json** if user explicitly needs it for CI/CD

### For Creating Resources:
1. Create files in `Auth0Tenant/` directory (not `tenant/`)
2. Follow Auth0 Deploy CLI directory structure
3. After creating files, suggest deploying with loaded credentials

### Default Directory Name:
- Use `Auth0Tenant/` as the default configuration directory
- This matches the project structure convention

## Troubleshooting

### Script Issues
- **"command not found"**: Ensure scripts are executable: `chmod +x scripts/*.sh`
- **"No tenant loaded"**: Load tenant first: `eval $(./scripts/load-tenant.sh <tenant>)`
- **"Tenant not found in keychain"**: Store credentials: `./scripts/store-tenant.sh <tenant>`
- **Shell compatibility**: Scripts work in both bash and zsh (POSIX-compliant)

### Auth0 CLI Issues
- Verify authentication: `auth0 tenants list`
- Re-authenticate: `auth0 login`
- Check API permissions in Auth0 Dashboard

### Deploy CLI Issues
- **With environment variables**: Ensure tenant is loaded (`./scripts/current-tenant.sh`)
- **With config.json**: Verify credentials and file format
- Check client has Management API permissions with required scopes:
  - `read:clients`, `create:clients`, `update:clients`
  - `read:resource_servers`, `create:resource_servers`, `update:resource_servers`
  - `read:actions`, `create:actions`, `update:actions`
  - `read:rules`, `create:rules`, `update:rules`
- Review error messages for specific resource issues

### Keychain Issues
- **Access denied**: Grant Terminal/shell access in System Preferences > Privacy & Security
- **Entry not found**: Verify tenant name with `./scripts/list-tenants.sh`
- **Multiple entries**: Each tenant has 3 keychain entries (domain, client_id, client_secret)
- All scripts use keychain pattern: `auth0_${tenant}_domain`, `auth0_${tenant}_client_id`, `auth0_${tenant}_client_secret`

## Resources

- [Auth0 CLI Documentation](https://auth0.com/docs/cli)
- [Auth0 Deploy CLI Documentation](https://github.com/auth0/auth0-deploy-cli)
- [Auth0 Actions Documentation](https://auth0.com/docs/customize/actions)
- [Auth0 Management API](https://auth0.com/docs/api/management/v2)

## When to Use This Skill

Claude should use this skill when users:
- Request creation of Auth0 resources (Actions, Rules, Hooks, etc.)
- Ask to deploy Auth0 configurations
- Need to manage multiple Auth0 tenants
- Want to work with Auth0 CLI or Deploy CLI
- Request Auth0-specific development assistance
- Ask about Auth0 best practices or project structure

## Example User Requests and Claude's Responses

### Creating Resources

**User:** "Create an action that checks whether a user has enrolled for MFA and if not start the MFA enrollment flow"

**Claude should:**
1. Check if `Auth0Tenant/` directory exists
2. Create `Auth0Tenant/actions/mfa-enrollment-check/` directory
3. Generate `code.js` with MFA enrollment logic
4. Generate `action.json` with proper configuration
5. Suggest deployment: `eval $(./scripts/load-tenant.sh <tenant>)` then `a0deploy import -i Auth0Tenant/`

### Deploying Changes

**User:** "Deploy my local changes to my tenant"

**Claude should:**
1. Check if tenant is loaded: Look for `$AUTH0_CUSTOMER` or suggest `./scripts/current-tenant.sh`
2. If not loaded: `eval $(./scripts/load-tenant.sh <tenant-name>)`
3. Deploy: `a0deploy import -i Auth0Tenant/`
4. Optionally suggest opening dashboard: `./scripts/dashboard.sh`

### Managing Credentials

**User:** "Store credentials for my dev tenant"

**Claude should:**
1. Guide user to run: `./scripts/store-tenant.sh dev-tenant`
2. Explain it will prompt for Domain, Client ID, and Client Secret
3. Suggest loading afterward: `eval $(./scripts/load-tenant.sh dev-tenant)`

**User:** "List all my configured Auth0 tenants"

**Claude should:**
1. Run: `./scripts/list-tenants.sh`
2. Explain the `[CURRENT]` marker shows loaded tenant

**User:** "Switch to my production tenant"

**Claude should:**
1. Show available tenants: `./scripts/list-tenants.sh`
2. Load prod tenant: `eval $(./scripts/load-tenant.sh prod-tenant)`
3. Verify: `./scripts/current-tenant.sh`

### Project Setup

**User:** "Set up a new Auth0 project with proper structure"

**Claude should:**
1. Create `Auth0Tenant/` with subdirectories (actions, rules, pages, etc.)
2. Set up `.gitignore` with `config.json`, `config.*.json`, `.env`
3. Guide user to store credentials: `./scripts/store-tenant.sh <tenant>`
4. Export existing config: `eval $(./scripts/load-tenant.sh <tenant>)` then `a0deploy export -f yaml -o Auth0Tenant/`

### Exporting Configuration

**User:** "Export my current tenant configuration"

**Claude should:**
1. Verify tenant is loaded: `./scripts/current-tenant.sh`
2. If not loaded: `eval $(./scripts/load-tenant.sh <tenant>)`
3. Export: `a0deploy export -f yaml -o Auth0Tenant/`

### Other Common Requests

- "Create a custom database connection script"
- "Add a new rule to enrich user profile with external data"
- "Open my Auth0 dashboard" → `./scripts/dashboard.sh`
- "Show me what tenant I'm currently working with" → `./scripts/current-tenant.sh`
- "Generate a config.json file for CI/CD" → `./scripts/create-config.sh <tenant> config.json`
