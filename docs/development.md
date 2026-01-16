# Development Guide

This guide covers the development workflow, architecture, and best practices for contributing to MCP Home Manager.

## Development Setup

### 1. Clone and Enter Development Environment

```bash
git clone https://github.com/yourusername/mcp-home-manager
cd mcp-home-manager
nix develop
```

The development shell includes:
- `nixpkgs-fmt` - Code formatter
- `statix` - Static analyzer
- `deadnix` - Unused code detector
- `nil` - Nix LSP server

### 2. Editor Configuration

#### VSCode/Cursor

Install the [Nix IDE](https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide) extension.

#### Neovim

Use [nil](https://github.com/oxalica/nil) or [nixd](https://github.com/nix-community/nixd) for LSP support.

## Project Architecture

### Directory Structure

```
mcp-home-manager/
├── modules/
│   ├── default.nix           # Main module entry point
│   ├── types.nix              # Type definitions
│   ├── builders.nix           # Config generation logic
│   └── servers/               # Server definitions
│       ├── default.nix        # Exports all server configs
│       ├── core.nix           # Servers with no dependencies
│       ├── integrations.nix   # Third-party API integrations
│       ├── optional.nix       # Optional utility servers
│       └── secrets.nix        # Servers requiring secrets
├── tests/                     # Configuration tests
│   ├── run-tests.sh          # Test runner
│   └── *.nix                 # Test configurations
├── examples/                  # Example configurations
├── docs/                      # Documentation
└── .github/                   # CI/CD and templates
    └── workflows/             # GitHub Actions
```

### Module System Flow

```
┌─────────────────────────────────────────┐
│ modules/default.nix                     │
│ ┌─────────────────────────────────────┐ │
│ │ Option Definitions                  │ │
│ │ - services.mcp.enable               │ │
│ │ - services.mcp.servers.*            │ │
│ │ - services.mcp.secretsPath          │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Import Sub-modules                  │ │
│ │ - types.nix    (type definitions)   │ │
│ │ - builders.nix (config builders)    │ │
│ │ - servers/     (server definitions) │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Merge Logic                         │ │
│ │ - Combine defaults + user config    │ │
│ │ - Filter enabled servers            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Generate Configs                    │ │
│ │ - Build MCP JSON configs            │ │
│ │ - Write to client paths             │ │
│ │ - Create activation scripts         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## Development Workflow

### Making Changes

1. **Create a branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes**
   Edit Nix files as needed

3. **Format code**
   ```bash
   nix fmt
   ```

4. **Run checks**
   ```bash
   nix flake check
   ```

5. **Run tests**
   ```bash
   ./tests/run-tests.sh
   ```

6. **Test locally**
   ```bash
   # Test in a minimal configuration
   nix eval --impure --expr '
     let
       nixpkgs = builtins.getFlake "nixpkgs";
       system = builtins.currentSystem;
       pkgs = nixpkgs.legacyPackages.${system};
       lib = pkgs.lib;
       config = { home.homeDirectory = "/home/testuser"; };
       mcpModule = import ./modules/default.nix { inherit config lib pkgs; };
       testConfig = import ./examples/basic.nix;
       evaluated = lib.evalModules {
         modules = [ mcpModule testConfig ];
       };
     in
       evaluated.config.services.mcp
   ' --json | jq .
   ```

### Adding a New Server

1. **Choose the appropriate file** in `modules/servers/`:
   - `core.nix` - No dependencies, no secrets
   - `integrations.nix` - Third-party APIs
   - `optional.nix` - Optional utilities
   - `secrets.nix` - Requires secret management

2. **Add server definition**:
   ```nix
   # In modules/servers/integrations.nix
   my-new-server = {
     command = "${pkgs.nodejs}/bin/npx";
     args = [ "-y" "my-server-package" ];
     secret = "MY_API_KEY"; # Optional
     enabled = false; # Default state
   };
   ```

3. **Export from `modules/servers/default.nix`**:
   ```nix
   {
     integrations = import ./integrations.nix { inherit config pkgs; };
   }
   ```

4. **Document in configuration.md**

5. **Add test case**:
   ```nix
   # tests/my-new-server.nix
   {
     services.mcp = {
       enable = true;
       servers.my-new-server.enabled = true;
     };
   }
   ```

6. **Add to test runner**:
   ```bash
   # In tests/run-tests.sh
   test_config "My new server" "$SCRIPT_DIR/my-new-server.nix"
   ```

### Testing Changes

#### Unit Testing

Individual configuration tests:

```bash
# Test a specific configuration
nix eval --impure --expr '
  let
    # ... setup ...
    testConfig = import ./tests/my-test.nix;
  in
    evaluated.config.services.mcp
' --json
```

#### Integration Testing

Test with actual clients:

1. Build your changes
2. Apply to a test user configuration
3. Verify generated JSON files
4. Test in Cursor/Claude Desktop

#### CI Testing

All CI checks run automatically on PR:

```bash
# Run what CI runs
nix fmt -- --check .
nix develop --command statix check .
nix develop --command deadnix --fail .
nix flake check --all-systems
./tests/run-tests.sh
```

## Code Style

### Nix Style Guide

- **Use `nixpkgs-fmt`** for consistent formatting
- **Prefer explicit over implicit** - make behavior clear
- **Document with comments** - explain why, not just what
- **Use meaningful names** - `activeServers` not `as`

### Module Options

Follow Nixpkgs conventions:

```nix
myOption = mkOption {
  type = types.str;
  default = "value";
  example = "example";
  description = ''
    Clear description of what this does.
    
    Can be multi-line.
  '';
};
```

### Server Definitions

Consistent structure:

```nix
server-name = {
  command = "...";           # Full path to executable
  args = [ ... ];            # Arguments list
  env = { ... };             # Optional environment vars
  secret = "SECRET_NAME";    # Optional secret reference
  enabled = false;           # Default enabled state
};
```

## Debugging

### Evaluate Configuration

```bash
# See what gets generated for a user config
nix eval .#homeConfigurations.myuser.config.services.mcp --json | jq .
```

### Check Generated JSON

```bash
# View Cursor config
cat ~/.cursor/mcp.json | jq .

# View Claude Desktop config
cat ~/.config/claude/claude_desktop_config.json | jq .
```

### Enable Trace Output

```nix
# In your test configuration
{
  services.mcp = {
    enable = true;
    _module.args.verbose = true; # If we add verbose mode
  };
}
```

### Common Issues

**Module evaluation fails:**
- Check for typos in attribute names
- Verify all required options are set
- Use `nix repl` to debug interactively

**Server not appearing:**
- Check `enabled = true` is set
- Verify server exists in merged config
- Check for JSON syntax errors

**Secret not found:**
- Verify secret file exists at `${secretsPath}/${secret}`
- Check file permissions
- Ensure sops-nix is configured correctly

## Performance Considerations

- **Lazy evaluation** - Nix only evaluates what's needed
- **Shallow merging** - Module system merges are efficient
- **JSON generation** - Happens at build time, not runtime
- **Secret reading** - Happens when server starts, not at build time

## Security Considerations

When adding servers:

1. **Never hardcode secrets** - Always use secret management
2. **Validate inputs** - Use appropriate Nix types
3. **Least privilege** - Don't require unnecessary permissions
4. **Document security implications** - Especially for filesystem access

## Documentation

### When to Update Docs

- **New servers** → Update `configuration.md`
- **New options** → Update `configuration.md`
- **Secret changes** → Update `secrets.md`
- **Install changes** → Update `installation.md`
- **Breaking changes** → Update `CHANGELOG.md` and migration guide

### Documentation Style

- Use clear, simple language
- Provide examples for complex topics
- Link between related sections
- Keep code examples up to date

## Release Process

See [CONTRIBUTING.md](../CONTRIBUTING.md) for release procedures.

## Getting Help

- **Questions** → [GitHub Discussions](https://github.com/yourusername/mcp-home-manager/discussions)
- **Bugs** → [GitHub Issues](https://github.com/yourusername/mcp-home-manager/issues)
- **Nix help** → [NixOS Discourse](https://discourse.nixos.org/)
- **MCP help** → [MCP Discord](https://discord.gg/modelcontextprotocol)

## Additional Resources

- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Module System](https://nixos.wiki/wiki/Module)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [MCP Specification](https://modelcontextprotocol.io/)
