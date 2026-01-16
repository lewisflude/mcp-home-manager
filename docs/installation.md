# Installation Guide

This guide covers how to install and set up MCP Home Manager in your Nix configuration.

## Prerequisites

- **Nix with flakes enabled** - See [NixOS Wiki](https://nixos.wiki/wiki/Flakes)
- **Home Manager** - See [Home Manager Manual](https://nix-community.github.io/home-manager/)
- One of the following MCP clients:
  - [Cursor](https://cursor.com/)
  - [Claude Desktop](https://claude.ai/download)

## Quick Start

### 1. Add to Your Flake

Add MCP Home Manager as an input to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-home-manager.url = "github:yourusername/mcp-home-manager";
  };

  outputs = { self, nixpkgs, home-manager, mcp-home-manager, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        mcp-home-manager.homeManagerModules.default
        ./home.nix
      ];
    };
  };
}
```

### 2. Enable in Home Configuration

In your `home.nix` (or equivalent):

```nix
{
  services.mcp = {
    enable = true;
    # Default servers (memory, git, time, sqlite, everything) are enabled automatically
  };
}
```

### 3. Rebuild

```bash
# For Home Manager standalone
home-manager switch --flake .

# For NixOS with Home Manager as module
sudo nixos-rebuild switch --flake .

# For nix-darwin
darwin-rebuild switch --flake .
```

## Platform-Specific Setup

### NixOS

```nix
# flake.nix
{
  outputs = { nixpkgs, home-manager, mcp-home-manager, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.users.youruser = {
            imports = [ mcp-home-manager.homeManagerModules.default ];
            services.mcp.enable = true;
          };
        }
      ];
    };
  };
}
```

### macOS (nix-darwin)

```nix
# flake.nix
{
  inputs.darwin.url = "github:lnl7/nix-darwin";
  
  outputs = { darwin, home-manager, mcp-home-manager, ... }: {
    darwinConfigurations.hostname = darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        {
          home-manager.users.youruser = {
            imports = [ mcp-home-manager.homeManagerModules.default ];
            services.mcp.enable = true;
          };
        }
      ];
    };
  };
}
```

### Standalone Home Manager

```nix
# flake.nix
{
  outputs = { home-manager, mcp-home-manager, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      modules = [
        mcp-home-manager.homeManagerModules.default
        {
          services.mcp.enable = true;
        }
      ];
    };
  };
}
```

## Configuration Locations

After installation, configuration files are created at:

### Linux
- **Cursor**: `~/.cursor/mcp.json`
- **Claude Desktop**: `~/.config/claude/claude_desktop_config.json`

### macOS
- **Cursor**: `~/.cursor/mcp.json`
- **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json`

## Verifying Installation

After rebuilding, you should see output like:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MCP Configuration Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Available servers:
  • memory
  • git
  • time
  • sqlite
  • everything

Configuration files:
  • Cursor: ~/.cursor/mcp.json
  • Claude Desktop: ~/.config/claude/claude_desktop_config.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Next Steps

- **Configure servers** - See [Configuration Reference](./configuration.md)
- **Add secrets** - See [Secret Management](./secrets.md)
- **Explore examples** - See [examples/](../examples/)

## Troubleshooting

### MCP servers not appearing in client

1. **Restart your MCP client** (Cursor/Claude Desktop)
2. **Check configuration file exists** at the locations above
3. **Verify JSON is valid**:
   ```bash
   cat ~/.cursor/mcp.json | jq .
   ```

### Permission errors

Ensure configuration directories exist:

```bash
mkdir -p ~/.cursor
mkdir -p ~/.config/claude  # Linux
mkdir -p ~/Library/Application\ Support/Claude  # macOS
```

### Flake evaluation errors

Update your flake inputs:

```bash
nix flake update
```

Check for Nix evaluation errors:

```bash
nix eval .#homeConfigurations.youruser.config.services.mcp --json
```

## Uninstalling

To remove MCP Home Manager:

1. Remove or disable in your configuration:
   ```nix
   services.mcp.enable = false;
   ```

2. Rebuild your system

3. Manually remove configuration files (optional):
   ```bash
   rm ~/.cursor/mcp.json
   rm ~/.config/claude/claude_desktop_config.json
   ```
