# Advanced MCP Configuration Example
#
# This example shows:
# - Enabling servers that require secrets
# - Adding custom MCP servers
# - Overriding default server configurations

{
  services.mcp = {
    enable = true;

    servers = {
      # Enable a server that requires a secret
      # Prerequisite: Configure GITHUB_TOKEN in your secrets management system
      github = {
        enabled = true;
        # The secret name must match your SOPS secret or other secret management
        secret = "GITHUB_TOKEN";
      };

      # Enable documentation server with OpenAI
      docs = {
        enabled = true;
        secret = "OPENAI_API_KEY";
      };

      # Override a default server configuration
      memory = {
        enabled = true;
        # You can override the command or args if needed
        args = [ "--custom-arg" ];
      };

      # Add a completely custom MCP server
      my-custom-server = {
        enabled = true;
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "my-custom-mcp-server"
        ];
        env = {
          # Custom environment variables
          MY_VAR = "value";
        };
        # Optional: if your server needs a secret
        secret = "MY_API_KEY";
      };

      # Disable a default server
      sqlite.enabled = false;
    };
  };
}
