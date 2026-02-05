# Auth0 CLI Quick Reference

## Auth0 CLI Commands

### Authentication
```bash
auth0 login                           # Interactive login
auth0 logout                          # Logout current session
auth0 tenants list                    # List available tenants
auth0 tenants use <domain>            # Switch active tenant
```

### Applications (Clients)
```bash
auth0 apps list                       # List all applications
auth0 apps show <client-id>           # Show application details
auth0 apps create                     # Create new application (interactive)
auth0 apps update <client-id>         # Update application
auth0 apps delete <client-id>         # Delete application
```

### APIs (Resource Servers)
```bash
auth0 apis list                       # List all APIs
auth0 apis show <api-id>              # Show API details
auth0 apis create                     # Create new API (interactive)
auth0 apis update <api-id>            # Update API
auth0 apis delete <api-id>            # Delete API
```

### Users
```bash
auth0 users list                      # List users
auth0 users show <user-id>            # Show user details
auth0 users create                    # Create new user (interactive)
auth0 users update <user-id>          # Update user
auth0 users delete <user-id>          # Delete user
auth0 users search <query>            # Search users
```

### Actions
```bash
auth0 actions list                    # List all actions
auth0 actions show <action-id>        # Show action details
auth0 actions create                  # Create new action (interactive)
auth0 actions update <action-id>      # Update action
auth0 actions delete <action-id>      # Delete action
auth0 actions deploy <action-id>      # Deploy action
```

### Logs
```bash
auth0 logs tail                       # Stream logs in real-time
auth0 logs list                       # List recent logs
auth0 logs show <log-id>              # Show specific log entry
```

### Roles
```bash
auth0 roles list                      # List all roles
auth0 roles show <role-id>            # Show role details
auth0 roles create                    # Create new role
auth0 roles permissions add           # Add permissions to role
```

## Auth0 Deploy CLI Commands

### Export Configuration
```bash
# Export to YAML (recommended)
a0deploy export \
  -c config.json \
  -f yaml \
  -o ./Auth0Tenant

# Export to directory format
a0deploy export \
  -c config.json \
  -f directory \
  -o ./Auth0Tenant

# Export specific resources only
a0deploy export \
  -c config.json \
  -f yaml \
  -o ./Auth0Tenant \
  --strip
```

### Import/Deploy Configuration
```bash
# Import from directory
a0deploy import \
  -c config.json \
  -i ./Auth0Tenant

# Dry run (preview changes without applying)
a0deploy import \
  -c config.json \
  -i ./Auth0Tenant \
  --dry-run

# Import with verbose output
a0deploy import \
  -c config.json \
  -i ./Auth0Tenant \
  --verbose
```

### Configuration Options

**config.json structure:**
```json
{
  "AUTH0_DOMAIN": "tenant.auth0.com",
  "AUTH0_CLIENT_ID": "client-id",
  "AUTH0_CLIENT_SECRET": "client-secret",
  "AUTH0_ALLOW_DELETE": false,
  "AUTH0_EXCLUDED_RULES": ["rule-name-to-exclude"],
  "AUTH0_EXCLUDED_CLIENTS": ["Auth0 Deploy CLI"],
  "AUTH0_EXCLUDED_RESOURCE_SERVERS": [],
  "AUTH0_EXCLUDED_DEFAULTS": ["emailProvider"],
  "AUTH0_EXPORT_IDENTIFIERS": false,
  "AUTH0_API_MAX_RETRIES": 10,
  "EXCLUDED_PROPS": {
    "clients": ["client_secret"]
  }
}
```

## Common Workflows

### 1. Initial Project Setup
```bash
# Create project structure
mkdir -p Auth0Tenant/{actions,rules,pages,databases}

# Export existing tenant configuration
./scripts/create-config.sh dev-tenant
a0deploy export -c config.json -f yaml -o Auth0Tenant/

# Initialize git
git init
git add .
git commit -m "Initial Auth0 configuration export"
```

### 2. Create and Deploy Action
```bash
# Create action directory
mkdir -p Auth0Tenant/actions/my-action

# Create code.js and action.json files
# (Claude can help generate these)

# Deploy to tenant
a0deploy import -c config.json -i Auth0Tenant/
```

### 3. Deploy to Multiple Environments
```bash
# Deploy to dev
./scripts/create-config.sh dev-tenant config.dev.json
a0deploy import -c config.dev.json -i Auth0Tenant/

# Deploy to staging
./scripts/create-config.sh staging-tenant config.staging.json
a0deploy import -c config.staging.json -i Auth0Tenant/

# Deploy to production (with dry-run first)
./scripts/create-config.sh prod-tenant config.prod.json
a0deploy import -c config.prod.json -i Auth0Tenant/ --dry-run
a0deploy import -c config.prod.json -i Auth0Tenant/
```

### 4. Backup Current Configuration
```bash
# Export with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
a0deploy export \
  -c config.json \
  -f yaml \
  -o "backups/Auth0Tenant_${TIMESTAMP}"
```

### 5. Sync Configuration Between Tenants
```bash
# Export from source tenant
./scripts/create-config.sh source-tenant config.source.json
a0deploy export -c config.source.json -f yaml -o temp-export/

# Import to destination tenant
./scripts/create-config.sh dest-tenant config.dest.json
a0deploy import -c config.dest.json -i temp-export/
```

## Auth0 Action Triggers

### Available Triggers
- `post-login` - After user login
- `credentials-exchange` - Machine-to-machine token exchange
- `pre-user-registration` - Before user registration
- `post-user-registration` - After user registration
- `post-change-password` - After password change
- `send-phone-message` - Customize SMS messages
- `iga-approval` - Identity governance approval
- `iga-certification` - Identity governance certification
- `iga-fulfillment` - Identity governance fulfillment

### Action Structure
```javascript
/**
 * @param {Event} event - Details about the event
 * @param {API} api - Interface to interact with Auth0
 */
exports.onExecute[TriggerName] = async (event, api) => {
  // Your code here
};
```

## Database Connection Scripts

### Script Types
- `login.js` - Custom user authentication
- `create.js` - Custom user creation
- `verify.js` - Email verification
- `change_password.js` - Password change logic
- `delete.js` - User deletion
- `get_user.js` - Retrieve user details

### Script Template
```javascript
function login(email, password, callback) {
  // Authenticate user
  // callback(error, user)
}
```

## Useful Environment Variables

```bash
# For Auth0 CLI
export AUTH0_DOMAIN="tenant.auth0.com"
export AUTH0_CLIENT_ID="client-id"
export AUTH0_CLIENT_SECRET="client-secret"

# For Deploy CLI (alternative to config.json)
export AUTH0_DOMAIN="tenant.auth0.com"
export AUTH0_CLIENT_ID="client-id"
export AUTH0_CLIENT_SECRET="client-secret"
export AUTH0_ALLOW_DELETE="false"
```

## Troubleshooting

### Common Issues

**Issue: "Insufficient scope"**
- Solution: Add required Management API scopes to your M2M application

**Issue: "Client not found"**
- Solution: Verify CLIENT_ID in config.json matches your M2M application

**Issue: "Rate limit exceeded"**
- Solution: Increase `AUTH0_API_MAX_RETRIES` in config.json

**Issue: "Resource already exists"**
- Solution: Use `a0deploy import` to update existing resources, not create new ones

### Debug Mode
```bash
# Enable verbose output
a0deploy import -c config.json -i Auth0Tenant/ --verbose

# Dry run to preview changes
a0deploy import -c config.json -i Auth0Tenant/ --dry-run
```

## Best Practices

1. **Always use dry-run for production deployments**
2. **Set `AUTH0_ALLOW_DELETE: false` to prevent accidental deletions**
3. **Exclude system clients** (Auth0 Deploy CLI, etc.)
4. **Use separate config files per environment**
5. **Keep backups before major changes**
6. **Test in dev tenant first**
7. **Use git for version control**
8. **Never commit config.json with credentials**
9. **Use keychain for local development**
10. **Use environment variables in CI/CD**
