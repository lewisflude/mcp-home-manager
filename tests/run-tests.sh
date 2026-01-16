#!/usr/bin/env bash
# Test harness for MCP Home Manager module configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "MCP Home Manager Module - Configuration Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

TESTS_PASSED=0
TESTS_FAILED=0

# Function to test a configuration
test_config() {
    local test_name="$1"
    local config_file="$2"

    echo "Testing: $test_name"

    # Create a minimal test expression that imports the module and config
    local test_expr
    test_expr=$(cat <<EOF
let
  nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/nixos-unstable";
  system = builtins.currentSystem;
  pkgs = nixpkgs.legacyPackages.\${system};
  lib = pkgs.lib;

  # Import the test config
  testConfig = import ${config_file};

  # Mock home-manager module that provides necessary options
  mockHomeManager = {
    options = {
      home.homeDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/testuser";
      };
      home.packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
      home.file = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
      home.activation = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
    };
  };

  # Evaluate the module with the test config
  evaluated = lib.evalModules {
    modules = [
      mockHomeManager
      ${PROJECT_DIR}/modules/default.nix
      testConfig
      {
        _module.args = { inherit pkgs; };
      }
    ];
  };
in
  evaluated.config.services.mcp
EOF
)

    if nix eval --impure --expr "$test_expr" --json > /dev/null 2>&1; then
        echo "  ✓ Configuration evaluates successfully"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "  ✗ Configuration evaluation failed"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi

    echo
}

# Run all tests
test_config "Default configuration" "$SCRIPT_DIR/default-config.nix"
test_config "Cursor only" "$SCRIPT_DIR/cursor-only.nix"
test_config "Claude Desktop only" "$SCRIPT_DIR/claude-only.nix"
test_config "Custom secret path" "$SCRIPT_DIR/custom-path.nix"
test_config "No clients" "$SCRIPT_DIR/no-clients.nix"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Passed: $TESTS_PASSED"
echo "  Failed: $TESTS_FAILED"
echo

if [ "$TESTS_FAILED" -gt 0 ]; then
    exit 1
fi

echo "✓ All tests passed"
