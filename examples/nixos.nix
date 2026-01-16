# NixOS Configuration Example
#
# This example shows how to integrate MCP Home Manager with NixOS

{ config, pkgs, ... }:

{
  # Import Home Manager NixOS module
  imports = [
    # Assuming you have home-manager configured as NixOS module
  ];

  # Home Manager configuration for a user
  home-manager.users.youruser = {
    # Import MCP Home Manager module
    imports = [
      # Add mcp-home-manager.homeManagerModules.default in your flake
    ];

    services.mcp = {
      enable = true;

      # NixOS-specific: Use user-readable secrets path
      secretsPath = "/run/secrets-for-users";

      # Configure for both clients
      clients = [ "cursor" "claude-desktop" ];

      servers = {
        # Core servers (enabled by default, no secrets needed)
        memory.enabled = true;
        git.enabled = true;
        time.enabled = true;
        sqlite.enabled = true;
        everything.enabled = true;

        # Integration servers (require secrets)
        github.enabled = true;
        openai.enabled = true;
        docs.enabled = true;
        kagi.enabled = true;

        # Optional utility servers
        fetch.enabled = true;
        sequentialthinking.enabled = true;
        nixos.enabled = true; # Particularly useful on NixOS!

        # Filesystem server (use with caution)
        # filesystem.enabled = true;
      };
    };
  };

  # System-level sops-nix configuration
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    age.keyFile = "/home/youruser/.config/sops/age/keys.txt";

    # Define secrets that will be accessible to user
    secrets = {
      github_token = {
        owner = config.users.users.youruser.name;
        mode = "0400";
        path = "/run/secrets-for-users/GITHUB_TOKEN";
      };

      openai_api_key = {
        owner = config.users.users.youruser.name;
        mode = "0400";
        path = "/run/secrets-for-users/OPENAI_API_KEY";
      };

      kagi_api_key = {
        owner = config.users.users.youruser.name;
        mode = "0400";
        path = "/run/secrets-for-users/KAGI_API_KEY";
      };
    };
  };

  # Ensure secrets directory exists with correct permissions
  system.activationScripts.mcp-secrets = ''
    mkdir -p /run/secrets-for-users
    chown root:users /run/secrets-for-users
    chmod 750 /run/secrets-for-users
  '';
}
