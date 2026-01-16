# Advanced MCP Configuration Example
#
# This example demonstrates advanced features:
# - Custom secret path configuration
# - Enabling servers that require secrets
# - Adding completely custom MCP servers
# - Overriding default server configurations
# - Configuring specific clients
# - Using environment variables

{ pkgs, ... }:

{
  services.mcp = {
    enable = true;

    # Configure custom secret path (default: /run/secrets)
    secretsPath = "/run/secrets-for-users";

    # Configure only specific clients
    clients = [ "cursor" ]; # Only generate config for Cursor, not Claude Desktop

    servers = {
      # ━━━ Enable Servers with Secrets ━━━

      # GitHub API integration
      github = {
        enabled = true;
        secret = "GITHUB_TOKEN"; # Must exist at ${secretsPath}/GITHUB_TOKEN
      };

      # OpenAI integration
      openai = {
        enabled = true;
        secret = "OPENAI_API_KEY";
      };

      # Documentation search with OpenAI
      docs = {
        enabled = true;
        secret = "OPENAI_API_KEY";
        # Can override command/args if needed
        # command = "${pkgs.nodejs}/bin/npx";
        # args = [ "-y" "@arabold/docs-mcp-server@latest" ];
      };

      # Kagi search integration
      kagi = {
        enabled = true;
        secret = "KAGI_API_KEY";
      };

      # ━━━ Enable Optional Servers ━━━

      # Web content fetching
      fetch.enabled = true;

      # Enhanced problem-solving tools
      sequentialthinking.enabled = true;

      # NixOS package search
      nixos.enabled = true;

      # ━━━ Override Default Servers ━━━

      # Customize the git server
      git = {
        enabled = true;
        # Could add custom args or environment
        env = {
          GIT_TRACE = "0"; # Disable git tracing
        };
      };

      # ━━━ Custom Servers ━━━

      # Example: Custom Python MCP server
      my-python-server = {
        enabled = true;
        command = "${pkgs.python3}/bin/python";
        args = [
          "-m"
          "my_mcp_package"
          "--port"
          "8080"
        ];
        env = {
          LOG_LEVEL = "debug";
          CACHE_DIR = "/tmp/my-server-cache";
        };
        secret = "MY_API_KEY"; # Optional
      };

      # Example: Custom Node.js server from NPM
      my-npm-server = {
        enabled = true;
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "my-mcp-server@latest"
          "--config"
          "/path/to/config.json"
        ];
        env = {
          NODE_ENV = "production";
        };
      };

      # Example: Custom local server binary
      my-local-server = {
        enabled = true;
        command = "/home/user/bin/my-mcp-server";
        args = [ "--mode" "production" ];
      };

      # ━━━ Disable Default Servers ━━━

      # Disable servers you don't need
      sqlite.enabled = false;
      everything.enabled = false; # Disable the test server
    };
  };
}

