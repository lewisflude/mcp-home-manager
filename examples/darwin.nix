# macOS (nix-darwin) Configuration Example
#
# This example shows how to integrate MCP Home Manager with nix-darwin

{ config, pkgs, ... }:

{
  # Import Home Manager darwin module
  imports = [
    # Assuming you have home-manager configured
  ];

  # Home Manager configuration
  home-manager.users.youruser = {
    # Import MCP Home Manager module
    imports = [
      # Add mcp-home-manager.homeManagerModules.default in your flake
    ];

    services.mcp = {
      enable = true;

      # macOS-specific: Claude Desktop config goes to
      # ~/Library/Application Support/Claude/claude_desktop_config.json

      servers = {
        # Enable core servers (enabled by default)
        memory.enabled = true;
        git.enabled = true;
        time.enabled = true;
        sqlite.enabled = true;

        # Enable servers with secrets (configure via sops-nix)
        github.enabled = true;
        openai.enabled = true;

        # macOS works great with these optional servers
        fetch.enabled = true;
        sequentialthinking.enabled = true;
      };
    };
  };

  # Configure sops-nix for macOS
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/Users/youruser/.config/sops/age/keys.txt";

    secrets = {
      github_token = {
        owner = "youruser";
        mode = "0400";
        path = "/run/secrets-for-users/GITHUB_TOKEN";
      };
      openai_api_key = {
        owner = "youruser";
        mode = "0400";
        path = "/run/secrets-for-users/OPENAI_API_KEY";
      };
    };
  };
}
