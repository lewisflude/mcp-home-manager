# MCP Home Manager Documentation

Welcome to the MCP Home Manager documentation! This guide will help you install, configure, and manage MCP servers with Nix.

## 📖 Documentation Index

### Getting Started

1. **[Installation Guide](./installation.md)**
   - Prerequisites and setup
   - Platform-specific installation (NixOS, macOS, standalone)
   - Verification and troubleshooting

2. **[Configuration Reference](./configuration.md)**
   - All configuration options explained
   - Built-in server documentation
   - Advanced configuration examples

3. **[Secret Management](./secrets.md)**
   - Secure API key handling
   - Integration with sops-nix and agenix
   - Platform-specific secret setup

### Additional Resources

- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute to the project
- **[Examples](../examples/)** - Real-world configuration examples
- **[Changelog](../CHANGELOG.md)** - Version history and changes

## 🚀 Quick Navigation

### Common Tasks

**First time setup:**
1. [Install MCP Home Manager](./installation.md#quick-start)
2. [Enable basic servers](./configuration.md#basic-options)
3. [Configure secrets](./secrets.md#quick-start-with-sops-nix)

**Adding servers with secrets:**
1. [Obtain API keys](./secrets.md#obtaining-api-keys)
2. [Configure secrets in sops](./secrets.md#3-create-secretssecrets-yaml)
3. [Enable servers](./configuration.md#integration-servers-require-secrets)

**Troubleshooting:**
- [Installation issues](./installation.md#troubleshooting)
- [Secret problems](./secrets.md#troubleshooting)
- [Debug configuration](./configuration.md#debugging)

## 💡 Quick Examples

### Minimal Setup

```nix
{
  services.mcp.enable = true;
  # That's it! Default servers are enabled automatically
}
```

### With GitHub Integration

```nix
{
  services.mcp = {
    enable = true;
    secretsPath = "/run/secrets-for-users";
    servers.github.enabled = true;
  };
}
```

### Custom Server

```nix
{
  services.mcp = {
    enable = true;
    servers.my-server = {
      command = "${pkgs.nodejs}/bin/node";
      args = [ "/path/to/server.js" ];
      env = { PORT = "8080"; };
    };
  };
}
```

## 🏗️ Architecture

MCP Home Manager follows this flow:

```
┌─────────────────┐
│  Nix Module     │  Declarative configuration
│  (services.mcp) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Server         │  Built-in + custom servers
│  Definitions    │  with secret handling
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Config Builder │  Generates JSON configs
│                 │  for MCP clients
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Client Configs │  ~/.cursor/mcp.json
│                 │  ~/.config/claude/...
└─────────────────┘
```

## 🎯 Design Goals

- **Declarative**: Configure everything through Nix options
- **Secure**: Integrate with existing secret management
- **Cross-platform**: Works on NixOS and macOS
- **Graceful**: Servers fail safely when secrets are missing
- **Flexible**: Easy to add custom servers

## 📦 Available Servers

### Core Servers (No Secrets Required)
- `memory` - Knowledge graph persistent memory
- `git` - Git repository operations
- `time` - Timezone utilities
- `sqlite` - SQLite database access
- `everything` - MCP reference server

### Integration Servers (Require Secrets)
- `github` - GitHub API integration
- `openai` - OpenAI API
- `docs` - Documentation search
- `kagi` - Kagi search API
- `brave` - Brave Search API

### Optional Servers
- `fetch` - Web content fetching
- `sequentialthinking` - Problem-solving tools
- `filesystem` - File operations (security-sensitive)
- `nixos` - NixOS package search

See [Configuration Reference](./configuration.md) for complete details.

## 🔗 External Resources

- [Model Context Protocol](https://modelcontextprotocol.io/) - Official MCP documentation
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - Home Manager docs
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/) - Nix packages
- [sops-nix](https://github.com/Mic92/sops-nix) - Secret management
- [Cursor](https://cursor.com/) - AI code editor
- [Claude Desktop](https://claude.ai/download) - Claude AI desktop app

## 🐛 Getting Help

- **Bug reports**: [GitHub Issues](https://github.com/lewisflude/mcp-home-manager/issues)
- **Questions**: [GitHub Discussions](https://github.com/lewisflude/mcp-home-manager/discussions)
- **Security issues**: Email maintainers (see main README)

## 📝 Contributing to Documentation

Found a typo? Want to improve explanations? Documentation PRs are welcome!

1. Edit files in `docs/`
2. Follow the [Contributing Guide](../CONTRIBUTING.md)
3. Submit a PR

## 📄 License

Documentation is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

Code is licensed under [MIT License](../LICENSE)
