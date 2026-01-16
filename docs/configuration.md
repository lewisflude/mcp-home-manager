# Configuration Reference

Complete reference for configuring MCP Home Manager.

## Basic Options

### `services.mcp.enable`

- **Type**: `boolean`
- **Default**: `false`
- **Description**: Enable MCP server configuration

```nix
services.mcp.enable = true;
```

### `services.mcp.clients`

- **Type**: `list of ("cursor" | "claude-desktop")`
- **Default**: `[ "cursor" "claude-desktop" ]`
- **Description**: Which MCP clients to configure

```nix
services.mcp.clients = [ "cursor" ];  # Only configure Cursor
```

### `services.mcp.secretsPath`

- **Type**: `path`
- **Default**: `"/run/secrets"`
- **Description**: Path to directory containing secret files

Common values:
- `/run/secrets` - Default for sops-nix with NixOS
- `/run/secrets-for-users` - For user-readable secrets
- `/run/agenix` - For agenix users
- Custom path for other secret managers

```nix
services.mcp.secretsPath = "/run/secrets-for-users";
```

## Server Configuration

### `services.mcp.servers`

- **Type**: `attribute set of server`
- **Default**: `{}`
- **Description**: MCP servers to configure

Each server can have these attributes:

#### `command`

- **Type**: `string`
- **Required**: Yes
- **Description**: Command to execute the server

```nix
services.mcp.servers.my-server.command = "${pkgs.nodejs}/bin/npx";
```

#### `args`

- **Type**: `list of string`
- **Default**: `[]`
- **Description**: Arguments passed to the command

```nix
services.mcp.servers.my-server.args = [ "-y" "my-package@latest" ];
```

#### `env`

- **Type**: `attribute set of string`
- **Default**: `{}`
- **Description**: Environment variables for the server

```nix
services.mcp.servers.my-server.env = {
  LOG_LEVEL = "debug";
  CUSTOM_VAR = "value";
};
```

#### `secret`

- **Type**: `string` or `null`
- **Default**: `null`
- **Description**: Name of secret file in `secretsPath`

```nix
services.mcp.servers.github.secret = "GITHUB_TOKEN";
```

The secret file at `${secretsPath}/${secret}` should contain the API key/token.

#### `enabled`

- **Type**: `boolean`
- **Default**: `true` for custom servers, varies for built-in servers
- **Description**: Whether to enable this server

```nix
services.mcp.servers.github.enabled = true;
```

## Built-in Servers

### Core Servers (Enabled by Default)

These servers require no secrets and are enabled automatically:

#### `memory`

Knowledge graph-based persistent memory.

```nix
services.mcp.servers.memory = {
  enabled = true;  # Default
  # Uses default configuration
};
```

#### `git`

Git repository operations.

```nix
services.mcp.servers.git = {
  enabled = true;  # Default
};
```

#### `time`

Timezone and datetime utilities.

```nix
services.mcp.servers.time = {
  enabled = true;  # Default
};
```

#### `sqlite`

SQLite database access.

```nix
services.mcp.servers.sqlite = {
  enabled = true;  # Default
};
```

#### `everything`

MCP reference/test server.

```nix
services.mcp.servers.everything = {
  enabled = true;  # Default
};
```

### Integration Servers (Require Secrets)

These servers require API keys and are disabled by default:

#### `github`

GitHub API integration.

```nix
services.mcp.servers.github = {
  enabled = true;
  secret = "GITHUB_TOKEN";  # Default
};
```

**Setup**: Create a [GitHub Personal Access Token](https://github.com/settings/tokens)

#### `openai`

OpenAI API integration.

```nix
services.mcp.servers.openai = {
  enabled = true;
  secret = "OPENAI_API_KEY";  # Default
};
```

**Setup**: Get API key from [OpenAI Platform](https://platform.openai.com/api-keys)

#### `docs`

Documentation indexing and search.

```nix
services.mcp.servers.docs = {
  enabled = true;
  secret = "OPENAI_API_KEY";  # Default
};
```

#### `kagi`

Kagi search integration.

```nix
services.mcp.servers.kagi = {
  enabled = true;
  secret = "KAGI_API_KEY";  # Default
};
```

**Setup**: Get API key from [Kagi Settings](https://kagi.com/settings?p=api)

#### `brave`

Brave Search API integration.

```nix
services.mcp.servers.brave = {
  enabled = true;
  secret = "BRAVE_API_KEY";  # Default
};
```

**Setup**: Get API key from [Brave Search API](https://brave.com/search/api/)

### Optional Servers

#### `fetch`

Web content fetching utilities.

```nix
services.mcp.servers.fetch = {
  enabled = true;
  # No secrets required
};
```

#### `sequentialthinking`

Enhanced problem-solving tool.

```nix
services.mcp.servers.sequentialthinking = {
  enabled = true;
  # No secrets required
};
```

#### `filesystem`

File operations (disabled by default for security).

```nix
services.mcp.servers.filesystem = {
  enabled = true;  # Use with caution
};
```

⚠️ **Security Note**: The filesystem server grants broad file access. Only enable if you trust the MCP client.

#### `nixos`

NixOS package search.

```nix
services.mcp.servers.nixos = {
  enabled = true;
  # Requires uv in PATH
};
```

## Advanced Configuration Examples

### Minimal Setup

```nix
{
  services.mcp = {
    enable = true;
    # Uses defaults: core servers + both clients
  };
}
```

### Cursor Only with GitHub

```nix
{
  services.mcp = {
    enable = true;
    clients = [ "cursor" ];
    servers.github.enabled = true;
  };
}
```

### Custom Server

```nix
{
  services.mcp = {
    enable = true;
    servers.my-custom-server = {
      command = "${pkgs.python3}/bin/python";
      args = [ "-m" "my_mcp_server" ];
      env = {
        LOG_LEVEL = "info";
      };
      secret = "MY_API_KEY";
    };
  };
}
```

### Override Default Server

```nix
{
  services.mcp = {
    enable = true;
    servers.git = {
      # Override the default git server configuration
      command = "${pkgs.nodejs}/bin/npx";
      args = [ "-y" "@modelcontextprotocol/server-git@latest" ];
      # Still enabled by default
    };
  };
}
```

### Disable Default Server

```nix
{
  services.mcp = {
    enable = true;
    servers.everything.enabled = false;  # Disable test server
  };
}
```

### All Features

```nix
{
  services.mcp = {
    enable = true;
    
    clients = [ "cursor" "claude-desktop" ];
    secretsPath = "/run/secrets-for-users";
    
    servers = {
      # Enable secret-requiring servers
      github.enabled = true;
      openai.enabled = true;
      docs.enabled = true;
      
      # Enable optional servers
      fetch.enabled = true;
      sequentialthinking.enabled = true;
      
      # Custom server
      my-server = {
        command = "${pkgs.nodejs}/bin/node";
        args = [ "/path/to/server.js" ];
        env = {
          PORT = "8080";
        };
      };
      
      # Disable a default server
      everything.enabled = false;
    };
  };
}
```

## Client-Specific Notes

### Cursor

- Configuration written to `~/.cursor/mcp.json`
- Restart Cursor after rebuilding to load changes
- Check MCP status in Cursor settings

### Claude Desktop

- Configuration locations:
  - Linux: `~/.config/claude/claude_desktop_config.json`
  - macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Restart Claude Desktop after rebuilding
- View MCP logs in Claude's developer console

## Debugging

### View Generated Configuration

```bash
# For Cursor
cat ~/.cursor/mcp.json | jq .

# For Claude Desktop (Linux)
cat ~/.config/claude/claude_desktop_config.json | jq .
```

### Check Server Status

During Home Manager activation, you'll see which servers are available:

```
✓ Available servers:
  • memory
  • git
  • github

⚠ Disabled servers (missing secrets):
  • openai (needs OPENAI_API_KEY at /run/secrets)
```

### Test Configuration

```bash
# Evaluate without building
nix eval .#homeConfigurations.youruser.config.services.mcp --json

# Check for evaluation errors
nix flake check
```

## See Also

- [Installation Guide](./installation.md)
- [Secret Management](./secrets.md)
- [Examples](../examples/)
