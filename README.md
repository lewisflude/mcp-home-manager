# MCP Home Manager

> Declarative MCP server management for Home Manager

**Status**: 🚧 Under active development - extracted from [personal Nix configuration](https://github.com/yourusername/nix-config)

## ✨ Highlights

- **Declarative Configuration**: Manage MCP servers through Nix options
- **Cross-Platform**: Works on both NixOS and macOS (nix-darwin)
- **Secret Management**: Integrates with SOPS for secure API key handling
- **Multiple Clients**: Configures Claude Desktop and Cursor automatically
- **Graceful Degradation**: Servers without secrets exit gracefully instead of crashing

## 🚀 Quick Start

```nix
{
  inputs.mcp-home-manager.url = "github:yourusername/mcp-home-manager";

  outputs = { self, nixpkgs, home-manager, mcp-home-manager, ... }: {
    homeConfigurations.youruser = home-manager.lib.homeManagerConfiguration {
      modules = [
        mcp-home-manager.homeManagerModules.default
        {
          services.mcp = {
            enable = true;
            # Default servers (memory, git, time, sqlite) are enabled automatically
          };
        }
      ];
    };
  };
}
```

## 📦 What's Included

**Enabled by default (no secrets required)**:
- `memory` - Knowledge graph-based persistent memory
- `git` - Git repository operations
- `time` - Timezone and datetime utilities
- `sqlite` - SQLite database access
- `everything` - MCP reference/test server

**Available (require secrets)**:
- `github` - GitHub API integration (needs `GITHUB_TOKEN`)
- `docs` - Documentation indexing (needs `OPENAI_API_KEY`)
- `openai` - OpenAI integration (needs `OPENAI_API_KEY`)
- And more...

## 📚 Documentation

> Documentation is being written as part of the extraction process.

- Installation Guide (coming soon)
- Configuration Reference (coming soon)
- Secret Management Guide (coming soon)
- Contributing Guide (coming soon)

## 🤝 Contributing

This project is in early stages. Contributions are welcome!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

[MIT License](LICENSE) - see LICENSE file for details.

## 🙏 Acknowledgments

- Extracted from a production Nix configuration
- Built with the [Model Context Protocol](https://modelcontextprotocol.io/)
- Inspired by the Nix community's excellent module system
