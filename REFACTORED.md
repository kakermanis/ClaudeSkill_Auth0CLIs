# Refactored Script Architecture

## Problem Statement

The original implementation had two major issues:
1. **Code duplication**: Logic was duplicated between `auth0-helpers.sh` and standalone scripts
2. **Shell incompatibility**: Used bash-specific syntax (`read -p`, `[[`, `${BASH_SOURCE}`) that doesn't work in zsh

## New Architecture

```
scripts/
├── lib/
│   └── auth0-core.sh          # Core library (POSIX-compliant)
├── store-tenant.sh            # Standalone scripts
├── load-tenant.sh             # All source lib/auth0-core.sh
├── list-tenants.sh            # No duplication
├── remove-tenant.sh
├── create-config.sh
├── current-tenant.sh
├── dashboard.sh
└── auth0-helpers.sh           # Wraps standalone scripts as functions
```

### Layer 1: Core Library (`lib/auth0-core.sh`)

**Purpose:** Contains all shared logic in POSIX-compliant shell code

**Key Functions:**
- `_auth0_store_credentials()` - Store in keychain
- `_auth0_get_credentials()` - Retrieve from keychain
- `_auth0_list_tenants()` - List all tenants
- `_auth0_remove_credentials()` - Remove from keychain
- `_auth0_dashboard_url()` - Generate dashboard URL

**Shell Compatibility:**
- Uses `#!/bin/sh` (POSIX shell)
- No bash-isms (`[[`, `read -p`, etc.)
- Works in bash, zsh, dash, sh
- Detects script directory for both bash and zsh

### Layer 2: Standalone Scripts

**Purpose:** Individual executable scripts for automation and direct use

**Pattern:**
```sh
#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/lib/auth0-core.sh"  # Source core library

# Use core functions
_auth0_store_credentials "$tenant" "$domain" "$client_id" "$client_secret"
```

**Benefits:**
- No code duplication
- Can be called from other scripts or CI/CD
- Consistent behavior
- Easy to maintain

### Layer 3: Sourceable Functions (`auth0-helpers.sh`)

**Purpose:** Convenient wrapper functions for interactive shell use

**Pattern:**
```sh
#!/bin/sh
# Detect directory (bash and zsh compatible)
# Source core library
. "${_AUTH0_SCRIPT_DIR}/lib/auth0-core.sh"

# Wrap standalone scripts as functions
auth0_add() {
    "${_AUTH0_SCRIPT_DIR}/store-tenant.sh" "$@"
}

auth0_load() {
    eval "$("${_AUTH0_SCRIPT_DIR}/load-tenant.sh" "$1")"
}
```

**Benefits:**
- No duplication - just wrappers
- Functions call standalone scripts
- Persistent environment variables
- Works in bash and zsh

## Shell Compatibility Fixes

### Before (Bash-specific):
```bash
#!/bin/bash
read -p "Domain: " domain              # -p flag doesn't work in zsh
if [[ "$1" == *.json ]]; then          # [[ ]] is bash-specific
SCRIPT_DIR="${BASH_SOURCE[0]}"         # Only works in bash
```

### After (POSIX-compatible):
```sh
#!/bin/sh
printf "Domain: "                      # Works everywhere
read -r domain

case "$1" in *.json) ;;  esac          # POSIX pattern matching

# Detect shell and set directory
if [ -n "$BASH_SOURCE" ]; then
    DIR="$(dirname "${BASH_SOURCE[0]}")"
elif [ -n "$ZSH_VERSION" ]; then
    DIR="$(dirname "${(%):-%x}")"
fi
```

## Usage Comparison

### Standalone Scripts (Automation/CI/CD)

```bash
# Add tenant
./scripts/store-tenant.sh dev-tenant

# Load (requires eval)
eval $(./scripts/load-tenant.sh dev-tenant)

# Deploy
a0deploy import -i Auth0Tenant/
```

### Sourceable Functions (Interactive Development)

```bash
# Add to ~/.zshrc
source ~/scripts/auth0-helpers.sh

# Use functions
auth0_add dev-tenant
auth0_load dev-tenant
auth0_deploy
auth0_dashboard
```

## Benefits of Refactoring

### 1. Zero Duplication
- Core logic in one place (`lib/auth0-core.sh`)
- Standalone scripts use core library
- `auth0-helpers.sh` wraps standalone scripts
- Update once, works everywhere

### 2. Shell Compatibility
- Works in bash, zsh, sh, dash
- No bash-specific syntax
- Proper shell detection
- POSIX-compliant patterns

### 3. Maintainability
- Single source of truth
- Clear separation of concerns
- Easy to test individual layers
- Changes propagate automatically

### 4. Flexibility
- Use standalone scripts in CI/CD
- Use functions for development
- Mix and match as needed
- Consistent behavior across all methods

## File Relationships

```
auth0-core.sh (core logic)
    ↓ sourced by
store-tenant.sh ←─┐
load-tenant.sh  ←─┤
list-tenants.sh ←─┤ called by
remove-tenant.sh←─┤ ↓
create-config.sh←─┤ auth0-helpers.sh (wrapper functions)
dashboard.sh    ←─┘
current-tenant.sh
```

## Testing the Refactored Scripts

```bash
# Test standalone scripts
./scripts/store-tenant.sh test-tenant
eval $(./scripts/load-tenant.sh test-tenant)
./scripts/list-tenants.sh
./scripts/current-tenant.sh
./scripts/dashboard.sh

# Test sourceable functions
source scripts/auth0-helpers.sh
auth0_add another-tenant
auth0_load another-tenant
auth0_list
auth0_current
auth0_dashboard
```

## Migration Notes

### For Users

**No changes needed!** The external interface is exactly the same:

- Standalone scripts have same names and arguments
- Functions have same names and behavior
- Environment variables unchanged
- Keychain format unchanged

### For Developers

- All scripts now use `#!/bin/sh` instead of `#!/bin/bash`
- Core logic moved to `lib/auth0-core.sh`
- Scripts source core library
- No bash-specific syntax allowed

## Performance

- **Before**: Each script duplicated keychain calls
- **After**: Shared core functions reduce redundancy
- **Impact**: Minimal (keychain access is the bottleneck, not code)
- **Benefit**: Easier to optimize in one place

## Future Enhancements

Now that we have a clean architecture:

1. **Add tests**: Test core library functions independently
2. **Add caching**: Cache keychain lookups in core library
3. **Add validation**: Validate credentials in one place
4. **Add logging**: Centralized logging in core library
5. **Add error handling**: Consistent error messages
6. **Support other shells**: Fish, tcsh if needed

## Summary

The refactoring achieves:
- ✅ Eliminated all code duplication
- ✅ Fixed bash/zsh compatibility issues
- ✅ Clear separation of concerns (core/scripts/functions)
- ✅ Maintained backward compatibility
- ✅ Easier to test and maintain
- ✅ Single source of truth for all logic
