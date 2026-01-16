# Standalone Home Manager Configuration Example
#
# This example shows how to use MCP Home Manager with standalone Home Manager
# (not integrated into NixOS or nix-darwin)

{ ... }:

{
  # This goes in your home.nix or equivalent

  # Import MCP Home Manager module
  imports = [
    # Add in your flake: mcp-home-manager.homeManagerModules.default
  ];

  services.mcp = {
    enable = true;

    # Default clients (both Cursor and Claude Desktop)
    clients = [ "cursor" "claude-desktop" ];

    servers = {
      # Core servers work without any secrets
      memory.enabled = true;
      git.enabled = true;
      time.enabled = true;
      sqlite.enabled = true;
      everything.enabled = true;

      # Optional servers (no secrets needed)
      fetch.enabled = true;
      sequentialthinking.enabled = true;

      # For servers requiring secrets with standalone Home Manager:
      # You'll need to manage secrets separately (e.g., using pass, 1Password CLI, etc.)
      # and ensure they're available at the secretsPath

      # Example: Using a custom secrets directory
      # github = {
      #   enabled = true;
      #   secret = "GITHUB_TOKEN"; # Will look in ${secretsPath}/GITHUB_TOKEN
      # };
    };

    # If you manage secrets outside of sops-nix/agenix,
    # point to where your secret files are stored
    # secretsPath = "${config.home.homeDirectory}/.secrets";
  };

  # If you're managing secrets manually, you could create a simple activation script
  # home.activation.setupMcpSecrets = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   mkdir -p ${config.home.homeDirectory}/.secrets
  #   # Copy secrets from secure location or use secret manager CLI
  #   # Example with pass:
  #   # ${pkgs.pass}/bin/pass github/token > ${config.home.homeDirectory}/.secrets/GITHUB_TOKEN
  # '';
}
