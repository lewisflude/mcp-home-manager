# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-01-16

### Added

**Core Module**
- Initial extraction of MCP Home Manager module
- Cross-platform support (NixOS + macOS)
- Default server configurations (memory, git, time, sqlite, everything)
- Secret management integration via sops-nix and agenix
- Support for Claude Desktop and Cursor clients
- Graceful degradation when secrets are missing
- Configurable secret paths and client selection

**Server Support**
- Core servers: memory, git, time, sqlite, everything
- Integration servers: github, openai, docs, kagi, brave
- Optional servers: fetch, sequentialthinking, filesystem, nixos
- Custom server support with full configuration options

**Documentation**
- Comprehensive installation guide for all platforms
- Complete configuration reference with examples
- Secret management guide for sops-nix and agenix
- Development guide with architecture details
- Contributing guidelines and code of conduct
- Project status and roadmap document
- Multiple real-world configuration examples

**CI/CD**
- Automated testing with formatting and linting
- Flake validation and example building
- Automated release workflow
- Weekly dependency updates
- PR and issue templates
- Dependabot configuration

**Examples**
- Basic configuration example
- Advanced configuration with customization
- Platform-specific examples (NixOS, macOS, standalone)
- Real-world usage patterns

[Unreleased]: https://github.com/lewisflude/mcp-home-manager/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/lewisflude/mcp-home-manager/releases/tag/v0.1.0
