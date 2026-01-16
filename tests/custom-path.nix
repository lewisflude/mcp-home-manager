# Test: Custom secret path with both clients
{
  services.mcp = {
    enable = true;
    secretsPath = "/home/user/.secrets";
    clients = [
      "cursor"
      "claude-desktop"
    ];

    # Enable a server with secrets to test path propagation
    servers.github.enabled = true;
  };
}
