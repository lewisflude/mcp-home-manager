# Basic test to verify the MCP module loads without errors
{ pkgs ? import <nixpkgs> { }
,
}:

let
  # Import home-manager's module evaluation framework
  eval = pkgs.lib.evalModules {
    modules = [
      ../modules/default.nix
      {
        # Minimal config to test module loading
        services.mcp.enable = true;

        # Mock required home-manager options
        home = {
          homeDirectory = "/home/testuser";
          packages = [ ];
          file = { };
          activation = { };
        };
      }
    ];
  };

  # Extract the config
  inherit (eval) config;

in
pkgs.runCommand "mcp-basic-test"
{
  buildInputs = [ pkgs.jq ];
}
  ''
    # Test that module loaded successfully
    if [ -z "${toString config.services.mcp.enable}" ]; then
      echo "ERROR: Module did not load properly"
      exit 1
    fi

    # Test that default servers are present
    echo "Testing default server configuration..."

    # Check that _generatedServers is populated
    ${
      if (config.services.mcp._generatedServers != { }) then
        ''echo "✓ Generated servers exist"''
      else
        ''
          echo "ERROR: No generated servers found"
          exit 1
        ''
    }

    echo "✓ Basic test passed"
    touch $out
  ''
