# MCP Home Manager

[![CI](https://github.com/yourusername/mcp-home-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/mcp-home-manager/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Declarative MCP server management for Home Manager

**Status**: 🚧 Under active development - extracted from production Nix configuration

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

Comprehensive documentation is available in the [`docs/`](./docs) directory:

- **[Installation Guide](./docs/installation.md)** - Get started with MCP Home Manager
- **[Configuration Reference](./docs/configuration.md)** - Complete configuration options
- **[Secret Management](./docs/secrets.md)** - Secure API key handling with sops-nix
- **[Contributing Guide](./CONTRIBUTING.md)** - Help improve this project
- **[Examples](./examples/)** - Real-world configuration examples

## 🤝 Contributing

Contributions are welcome! Whether you're fixing bugs, adding features, or improving documentation, we appreciate your help.

- Read the [Contributing Guide](./CONTRIBUTING.md)
- Check [open issues](https://github.com/yourusername/mcp-home-manager/issues)
- Join discussions in [GitHub Discussions](https://github.com/yourusername/mcp-home-manager/discussions)

### Development

```bash
# Enter development shell
nix develop

# Format code
nix fmt

# Run checks
nix flake check

# Run tests
./tests/run-tests.sh
```

## 📄 License

[MIT License](LICENSE) - see LICENSE file for details.

## 📊 Project Status

This project is actively developed and production-ready. See [PROJECT_STATUS.md](./PROJECT_STATUS.md) for detailed status, roadmap, and known issues.

## 🙏 Acknowledgments

- Extracted from a production Nix configuration
- Built with the [Model Context Protocol](https://modelcontextprotocol.io/)
- Inspired by the Nix community's excellent module system

## 🔗 Links

- [Documentation](./docs/)
- [Examples](./examples/)
- [Contributing](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)
- [License](./LICENSE)
