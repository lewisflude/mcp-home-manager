# Secret Management Guide

Learn how to securely manage API keys and tokens for MCP servers.

## Overview

Many MCP servers require API keys or authentication tokens. MCP Home Manager integrates with Nix secret management tools to handle these securely.

**Supported secret managers:**
- [sops-nix](https://github.com/Mic92/sops-nix) - Recommended
- [agenix](https://github.com/ryantm/agenix)
- Custom solutions (any system that writes secrets to files)

## How It Works

1. Secrets are stored as files in a configured directory
2. Each server references its required secret by name
3. At runtime, the server reads the secret from the file
4. Servers gracefully exit if their secret is missing (no crashes!)

## Quick Start with sops-nix

### 1. Install sops-nix

Add to your flake:

```nix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";
  
  outputs = { sops-nix, ... }: {
    nixosConfigurations.hostname = {
      modules = [ sops-nix.nixosModules.sops ];
    };
  };
}
```

### 2. Create `.sops.yaml`

```yaml
# .sops.yaml
keys:
  - &admin your_age_public_key_here

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *admin
```

### 3. Create `secrets/secrets.yaml`

```bash
# Create encrypted secrets file
sops secrets/secrets.yaml
```

Add your secrets (SOPS will encrypt on save):

```yaml
# secrets/secrets.yaml
github_token: ghp_your_token_here
openai_api_key: sk-your_key_here
kagi_api_key: your_kagi_key_here
```

### 4. Configure sops-nix

```nix
# For user secrets (recommended)
{
  sops = {
    age.keyFile = "/home/youruser/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    
    secrets = {
      # Make secrets readable by user
      github_token = {
        mode = "0400";
        owner = config.users.users.youruser.name;
        path = "/run/secrets-for-users/GITHUB_TOKEN";
      };
      openai_api_key = {
        mode = "0400";
        owner = config.users.users.youruser.name;
        path = "/run/secrets-for-users/OPENAI_API_KEY";
      };
    };
  };
}
```

### 5. Configure MCP to Use Secrets

```nix
{
  services.mcp = {
    enable = true;
    secretsPath = "/run/secrets-for-users";
    
    servers = {
      github.enabled = true;   # Will use GITHUB_TOKEN
      openai.enabled = true;   # Will use OPENAI_API_KEY
    };
  };
}
```

## Platform-Specific Setup

### NixOS

```nix
# configuration.nix or flake
{
  imports = [ sops-nix.nixosModules.sops ];
  
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/home/youruser/.config/sops/age/keys.txt";
    
    secrets.github_token = {
      owner = config.users.users.youruser.name;
      path = "/run/secrets-for-users/GITHUB_TOKEN";
    };
  };
  
  # In Home Manager config
  home-manager.users.youruser = {
    services.mcp = {
      enable = true;
      secretsPath = "/run/secrets-for-users";
      servers.github.enabled = true;
    };
  };
}
```

### macOS (nix-darwin)

```nix
# darwin-configuration.nix
{
  imports = [ sops-nix.darwinModules.sops ];
  
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/Users/youruser/.config/sops/age/keys.txt";
    
    secrets.github_token = {
      owner = "youruser";
      path = "/run/secrets-for-users/GITHUB_TOKEN";
    };
  };
  
  home-manager.users.youruser = {
    services.mcp = {
      enable = true;
      secretsPath = "/run/secrets-for-users";
      servers.github.enabled = true;
    };
  };
}
```

### Standalone Home Manager

With standalone Home Manager, you'll need to manage secrets at the system level or use a user-level secret manager.

## Using agenix

### Setup

```nix
{
  inputs.agenix.url = "github:ryantm/agenix";
  
  outputs = { agenix, ... }: {
    nixosConfigurations.hostname = {
      modules = [ agenix.nixosModules.default ];
    };
  };
}
```

### Configure

```nix
{
  age = {
    secrets.github_token.file = ./secrets/github_token.age;
    secrets.openai_api_key.file = ./secrets/openai_api_key.age;
  };
  
  services.mcp = {
    enable = true;
    secretsPath = "/run/agenix";  # Default agenix location
    servers.github.enabled = true;
  };
}
```

## Custom Secret Management

If you're using a custom secret management solution:

1. Ensure secrets are written as files
2. Point `secretsPath` to your secret directory
3. Ensure secret files have appropriate permissions

```nix
{
  services.mcp = {
    enable = true;
    secretsPath = "/path/to/your/secrets";
    servers.github = {
      enabled = true;
      secret = "GITHUB_TOKEN";  # Will read from /path/to/your/secrets/GITHUB_TOKEN
    };
  };
}
```

## Secret Naming Convention

Default secret names for built-in servers:

| Server | Secret Name | Format |
|--------|-------------|--------|
| `github` | `GITHUB_TOKEN` | `ghp_...` or `github_pat_...` |
| `openai` | `OPENAI_API_KEY` | `sk-...` |
| `docs` | `OPENAI_API_KEY` | `sk-...` |
| `kagi` | `KAGI_API_KEY` | String |
| `brave` | `BRAVE_API_KEY` | String |

### Custom Secret Names

You can override the secret name:

```nix
{
  services.mcp.servers.github = {
    enabled = true;
    secret = "MY_GITHUB_TOKEN";  # Use custom name
  };
}
```

## Obtaining API Keys

### GitHub Token

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Select scopes based on needs (typically: `repo`, `read:org`)
4. Copy the token (starts with `ghp_` or `github_pat_`)

### OpenAI API Key

1. Visit [OpenAI Platform](https://platform.openai.com/)
2. Go to API keys section
3. Create a new secret key
4. Copy the key (starts with `sk-`)

### Kagi API Key

1. Go to [Kagi Settings → API](https://kagi.com/settings?p=api)
2. Enable API access
3. Generate an API key
4. Copy the key

### Brave Search API Key

1. Visit [Brave Search API](https://brave.com/search/api/)
2. Sign up for API access
3. Generate an API key
4. Copy the key

## Security Best Practices

### ✅ Do

- **Use age encryption** for your secrets
- **Set restrictive permissions** (0400 or 0600)
- **Keep secrets out of Git** (`.sops.yaml` defines encryption, not the secrets themselves)
- **Rotate keys periodically**
- **Use separate keys per environment** (dev/prod)

### ❌ Don't

- **Never commit unencrypted secrets** to Git
- **Don't share private keys** (age keys, GPG keys)
- **Avoid overly permissive scopes** when creating tokens
- **Don't use root-owned secrets** for user services

## Graceful Degradation

MCP Home Manager handles missing secrets gracefully:

```nix
{
  services.mcp = {
    enable = true;
    servers = {
      github.enabled = true;  # Secret available
      openai.enabled = true;  # Secret missing
    };
  };
}
```

During activation:

```
✓ Available servers:
  • memory
  • git
  • github

⚠ Disabled servers (missing secrets):
  • openai (needs OPENAI_API_KEY at /run/secrets-for-users)

These servers will exit gracefully and won't cause MCP errors.
```

**Benefits:**
- No crashes or errors in MCP clients
- Can enable servers before secrets are ready
- Easy to see which secrets are missing

## Troubleshooting

### Secret file not found

**Error**: Server disabled due to missing secret

**Solutions**:
1. Check secret exists: `ls -la /run/secrets-for-users/GITHUB_TOKEN`
2. Verify `secretsPath` is correct
3. Check file permissions (should be readable by your user)
4. Rebuild system after adding secrets

### Permission denied reading secret

**Error**: Cannot read secret file

**Solutions**:
1. Check file ownership: `ls -la /run/secrets-for-users/`
2. Ensure secret is owned by your user or readable
3. In sops-nix config, set correct `owner`:
   ```nix
   sops.secrets.github_token.owner = "youruser";
   ```

### Server still not working with valid secret

**Debugging steps**:
1. Verify secret content is correct (not empty, no extra whitespace)
2. Check MCP client logs
3. Test server manually:
   ```bash
   GITHUB_TOKEN=$(cat /run/secrets-for-users/GITHUB_TOKEN) npx -y @modelcontextprotocol/server-github
   ```

### Age key not found

**Error**: Cannot decrypt secrets

**Solutions**:
1. Generate age key: `age-keygen -o ~/.config/sops/age/keys.txt`
2. Add public key to `.sops.yaml`
3. Re-encrypt secrets: `sops updatekeys secrets/secrets.yaml`

## Example: Complete Setup

Here's a complete example with sops-nix:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    sops-nix.url = "github:Mic92/sops-nix";
    mcp-home-manager.url = "github:lewisflude/mcp-home-manager";
  };

  outputs = { nixpkgs, home-manager, sops-nix, mcp-home-manager, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          # System-level sops config
          sops = {
            defaultSopsFile = ./secrets/secrets.yaml;
            age.keyFile = "/home/youruser/.config/sops/age/keys.txt";
            
            secrets = {
              github_token = {
                owner = "youruser";
                mode = "0400";
                path = "/run/secrets-for-users/GITHUB_TOKEN";
              };
              openai_api_key = {
                owner = "youruser";
                mode = "0400";
                path = "/run/secrets-for-users/OPENAI_API_KEY";
              };
            };
          };

          # Home Manager config
          home-manager.users.youruser = {
            imports = [ mcp-home-manager.homeManagerModules.default ];
            
            services.mcp = {
              enable = true;
              secretsPath = "/run/secrets-for-users";
              
              servers = {
                github.enabled = true;
                openai.enabled = true;
                docs.enabled = true;
              };
            };
          };
        }
      ];
    };
  };
}
```

## See Also

- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [agenix Documentation](https://github.com/ryantm/agenix)
- [Configuration Reference](./configuration.md)
- [Installation Guide](./installation.md)
