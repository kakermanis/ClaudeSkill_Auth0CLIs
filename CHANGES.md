# Script Changes Summary

Based on the pattern from `/draft/.auth0-helper.sh`, I've refactored all scripts to better support multiple tenants with environment variable management.

## Key Changes

### 1. Keychain Naming Convention ✅

**Old Pattern:**
```
Service: auth0-tenant-domain
Account: <tenant-name>
```

**New Pattern (matches draft):**
```
Service: auth0_${tenant}_domain
Account: $USER
```

**Why:** This keeps credentials tied to the macOS user account and makes the tenant name part of the service identifier, which is cleaner for extraction.

### 2. Environment Variable Export ✅

**Old Behavior:**
```bash
./get-tenant.sh dev-tenant
# Output: DOMAIN=... CLIENT_ID=... CLIENT_SECRET=...
```

**New Behavior:**
```bash
eval $(./load-tenant.sh dev-tenant)
# Sets: $AUTH0_CUSTOMER, $AUTH0_DOMAIN, $AUTH0_CLIENT_ID, $AUTH0_CLIENT_SECRET
```

**Why:** Auth0 Deploy CLI can now use environment variables directly without needing config.json!

### 3. Current Tenant Context ✅

**New Feature:** Scripts now recognize `$AUTH0_CUSTOMER` to track which tenant is loaded.

- `list-tenants.sh` highlights current tenant with `[CURRENT]`
- `current-tenant.sh` shows which tenant is active
- `create-config.sh` can use loaded tenant without specifying

### 4. Dual Approach (Hybrid) ✅

**Sourceable Functions:** `auth0-helpers.sh`
- Source once in shell: `source scripts/auth0-helpers.sh`
- Use functions: `auth0_load`, `auth0_deploy`, etc.
- Environment persists across commands
- Best for interactive development

**Standalone Scripts:**
- Call individually: `./scripts/load-tenant.sh`
- Use in other scripts or automation
- Requires `eval` for environment variables
- Best for CI/CD and scripting

## Updated Scripts

### Modified Scripts

1. **store-tenant.sh**
   - Uses `auth0_${tenant}_*` pattern
   - Uses `-a "$USER"` instead of tenant name
   - Supports interactive mode (no args except tenant name)
   - Supports non-interactive mode (all args provided)

2. **load-tenant.sh** (renamed from get-tenant.sh)
   - Outputs `export` statements for eval
   - Sets `AUTH0_CUSTOMER`, `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`
   - Must be used with `eval`

3. **list-tenants.sh**
   - Simpler regex pattern: `auth0_.*_domain`
   - Shows `[CURRENT]` for loaded tenant
   - Cleaner extraction logic

4. **remove-tenant.sh**
   - Uses new pattern
   - Warns if removing currently loaded tenant
   - Suggests unsetting env vars

5. **create-config.sh**
   - Can use currently loaded tenant (no args needed)
   - Checks `$AUTH0_CUSTOMER` first
   - Falls back to keychain if needed
   - Smarter argument parsing

### New Scripts

6. **current-tenant.sh** ⭐
   - Shows which tenant is loaded
   - Displays all environment variables
   - Helpful for debugging

7. **dashboard.sh** ⭐
   - Opens Auth0 dashboard in browser
   - Supports public and private cloud URLs
   - Can use loaded tenant or specify one

8. **auth0-helpers.sh** ⭐
   - All-in-one sourceable file
   - Contains all functions from draft
   - Plus: `auth0_deploy`, `auth0_export`, `auth0_unload`, `auth0_help`
   - Matches draft pattern exactly

## Workflow Improvements

### Before (Old Scripts)

```bash
# Get credentials
./scripts/get-tenant.sh dev-tenant

# Parse output manually
# Create config.json manually
# Run deploy with config.json
a0deploy import -c config.json -i Auth0Tenant/
```

### After (New Scripts - Standalone)

```bash
# Load credentials into environment
eval $(./scripts/load-tenant.sh dev-tenant)

# Deploy directly (uses env vars!)
a0deploy import -i Auth0Tenant/
```

### After (New Scripts - Functions)

```bash
# One-time: source functions
source scripts/auth0-helpers.sh

# Daily workflow
auth0_load dev-tenant
auth0_deploy              # Runs a0deploy with env vars
auth0_dashboard           # Opens browser
```

## Benefits

1. **No config.json needed** - Deploy CLI uses env vars automatically
2. **Tenant context awareness** - Scripts know which tenant is loaded
3. **Faster workflow** - Load once, run multiple commands
4. **Better multi-tenant support** - Easy to switch between tenants
5. **Dashboard access** - Quick browser access to Auth0 dashboard
6. **Flexible usage** - Choose standalone scripts OR sourceable functions

## Breaking Changes

⚠️ **Keychain entries must be recreated** - Old `auth0-tenant-*` entries won't work

Migration:
```bash
# Remove old entries
./scripts/remove-tenant.sh old-tenant  # (might fail, that's ok)

# Add with new pattern
./scripts/store-tenant.sh old-tenant
```

## Backward Compatibility

- Script names changed: `get-tenant.sh` → `load-tenant.sh`
- Usage changed: `./get-tenant.sh` → `eval $(./load-tenant.sh)`
- Keychain pattern changed: Must re-add tenants

## Testing Checklist

- [ ] Store new tenant credentials
- [ ] Load tenant and verify env vars
- [ ] List tenants (should show [CURRENT])
- [ ] Show current tenant
- [ ] Create config.json from loaded tenant
- [ ] Open dashboard
- [ ] Deploy without config.json
- [ ] Switch to another tenant
- [ ] Remove tenant credentials
- [ ] Source auth0-helpers.sh and use functions

## Documentation Updated

- [x] `scripts/README.md` - Complete usage guide
- [x] Main `README.md` - Updated examples
- [x] `skill.md` - Update Claude's instructions (TODO)
- [x] `QUICKREF.md` - Update CLI reference (TODO)

## Next Steps

1. Update `skill.md` to teach Claude the new script patterns
2. Update `QUICKREF.md` with new workflow examples
3. Test all scripts thoroughly
4. Consider adding fish/zsh completion scripts
5. Add CI/CD examples
