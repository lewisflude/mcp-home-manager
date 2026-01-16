# Simple evaluation test that imports the module and tests various configurations
{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
,
}:

let
  # Helper to evaluate a configuration with the MCP module
  evalConfig =
    testConfig:
    lib.evalModules {
      modules = [
        # Minimal home-manager-like module
        {
          options = {
            home = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  homeDirectory = lib.mkOption {
                    type = lib.types.str;
                    default = "/home/testuser";
                  };
                  packages = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [ ];
                  };
                  file = lib.mkOption {
                    type = lib.types.attrs;
                    default = { };
                  };
                  activation = lib.mkOption {
                    type = lib.types.attrs;
                    default = { };
                  };
                };
              };
            };
          };
        }
        # Import the MCP module
        (import ../modules/default.nix)
        # Apply test configuration
        testConfig
      ];
      specialArgs = { inherit pkgs lib; };
    };

  # Test configurations
  tests = {
    default = evalConfig { services.mcp.enable = true; };

    cursorOnly = evalConfig {
      services.mcp = {
        enable = true;
        clients = [ "cursor" ];
      };
    };

    claudeOnly = evalConfig {
      services.mcp = {
        enable = true;
        clients = [ "claude-desktop" ];
      };
    };

    customSecretPath = evalConfig {
      services.mcp = {
        enable = true;
        secretsPath = "/run/agenix";
      };
    };

    withSecretServer = evalConfig {
      services.mcp = {
        enable = true;
        secretsPath = "/run/secrets-for-users";
        servers.github.enabled = true;
      };
    };
  };

  # Verify key properties
  verifyConfig =
    name: cfg:
    let
      mcpCfg = cfg.config.services.mcp;
    in
    {
      inherit name;
      enabled = mcpCfg.enable;
      inherit (mcpCfg) secretsPath clients;
      serverCount = lib.length (lib.attrNames mcpCfg._generatedServers);
      hasGenerated = mcpCfg._generatedServers != { };
    };

  results = lib.mapAttrs verifyConfig tests;

in
{
  inherit tests results;

  # Summary
  summary = {
    testCount = lib.length (lib.attrNames tests);
    allEnabled = lib.all (t: t.enabled) (lib.attrValues results);
    secretPathsCorrect = {
      default = results.default.secretsPath == "/run/secrets";
      custom = results.customSecretPath.secretsPath == "/run/agenix";
      withSecret = results.withSecretServer.secretsPath == "/run/secrets-for-users";
    };
    clientsCorrect = {
      default = lib.length results.default.clients == 2;
      cursorOnly = results.cursorOnly.clients == [ "cursor" ];
      claudeOnly = results.claudeOnly.clients == [ "claude-desktop" ];
    };
  };
}
