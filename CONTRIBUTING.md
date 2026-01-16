# Contributing to MCP Home Manager

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## 🚀 Quick Start

1. **Fork and Clone**
   ```bash
   git clone https://github.com/yourusername/mcp-home-manager
   cd mcp-home-manager
   ```

2. **Enter Development Shell**
   ```bash
   nix develop
   ```
   This provides:
   - `nixpkgs-fmt` - Nix code formatter
   - `statix` - Linter for Nix
   - `deadnix` - Find unused Nix code
   - `nil` - Nix LSP server

3. **Make Your Changes**
   - Follow the project structure
   - Write clear, documented code
   - Add tests for new features

4. **Test Your Changes**
   ```bash
   # Format code
   nix fmt
   
   # Check flake
   nix flake check
   
   # Run tests
   ./tests/run-tests.sh
   ```

5. **Submit a Pull Request**

## 📁 Project Structure

```
mcp-home-manager/
├── modules/
│   ├── default.nix      # Main module entry point
│   ├── types.nix        # Type definitions
│   ├── builders.nix     # Configuration builders
│   └── servers/         # Server definitions
│       ├── default.nix  # Exports all servers
│       ├── core.nix     # Core servers (no secrets)
│       ├── integrations.nix  # Third-party integrations
│       ├── optional.nix # Optional utility servers
│       └── secrets.nix  # Secret-requiring servers
├── tests/               # Configuration tests
├── examples/            # Example configurations
├── docs/                # Documentation
└── .github/workflows/   # CI/CD pipelines
```

## 🧪 Testing

### Running Tests

All tests should pass before submitting a PR:

```bash
# Run all tests
./tests/run-tests.sh

# Individual checks
nix flake check           # Formatting and build checks
nix fmt                   # Format all Nix files
nix build .#checks.x86_64-linux.format  # Check formatting only
```

### Adding Tests

Create test configurations in `tests/`:

```nix
# tests/my-feature.nix
{
  services.mcp = {
    enable = true;
    # Test your feature here
  };
}
```

Add to `tests/run-tests.sh`:

```bash
test_config "My feature" "$SCRIPT_DIR/my-feature.nix"
```

## 📝 Coding Guidelines

### Nix Style

- Use `nixpkgs-fmt` for consistent formatting
- Follow Nixpkgs conventions
- Document all options with clear descriptions
- Use meaningful variable names

### Module Options

When adding new options:

1. Add clear descriptions
2. Provide examples
3. Set sensible defaults
4. Document any platform-specific behavior

Example:

```nix
myOption = mkOption {
  type = types.str;
  default = "default-value";
  example = "example-value";
  description = ''
    Clear description of what this option does.
    
    Multi-line descriptions are fine.
  '';
};
```

### Server Definitions

New servers should be added to the appropriate file in `modules/servers/`:

- `core.nix` - Servers with no dependencies or secrets
- `integrations.nix` - Third-party API integrations
- `optional.nix` - Optional utility servers
- `secrets.nix` - Servers requiring secret management

Example server definition:

```nix
my-server = {
  command = "${pkgs.nodejs}/bin/npx";
  args = [ "-y" "my-server-package" ];
  secret = "MY_API_KEY";  # Optional
  enabled = false;  # Default state
};
```

## 🔍 Code Review Process

Pull requests should:

1. **Pass all CI checks** - Tests, linting, formatting
2. **Include tests** - For new features or bug fixes
3. **Update documentation** - If changing public API
4. **Have clear commit messages** - Explain what and why
5. **Reference issues** - If applicable

### Commit Message Format

```
type: brief description

Longer explanation if needed. Explain what changed and why,
not just how.

Fixes #123
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions or changes
- `ci:` - CI/CD changes
- `chore:` - Maintenance tasks

## 🐛 Reporting Issues

When reporting issues, please include:

1. **Environment**
   - OS (NixOS/macOS)
   - Nix version (`nix --version`)
   - MCP client (Cursor/Claude Desktop)

2. **Configuration**
   - Relevant parts of your config
   - Which servers are enabled

3. **Steps to Reproduce**
   - Clear, numbered steps
   - Expected vs actual behavior

4. **Logs/Errors**
   - Error messages
   - Relevant log output

## 💡 Feature Requests

We welcome feature requests! Please:

1. Check existing issues first
2. Describe the use case
3. Explain the expected behavior
4. Consider implementation approach (if applicable)

## 📚 Documentation

Documentation improvements are always welcome:

- Fix typos or unclear sections
- Add examples
- Improve explanations
- Translate documentation (future)

## 🔒 Security

If you discover a security issue:

1. **Do not** open a public issue
2. Email the maintainers (details in README)
3. Provide detailed information
4. Allow time for a fix before disclosure

## 🎯 Areas for Contribution

Looking to contribute but not sure where to start? Consider:

- **Documentation** - Always room for improvement
- **Tests** - Increase coverage
- **New Servers** - Add support for more MCP servers
- **Platform Support** - Test on different systems
- **Examples** - Add more usage examples
- **Bug Fixes** - Check the issue tracker

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 Thank You

Your contributions help make this project better for everyone!
