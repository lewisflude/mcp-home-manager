# Test: Claude Desktop client only with agenix path
{
  services.mcp = {
    enable = true;
    secretsPath = "/run/agenix";
    clients = [ "claude-desktop" ];
  };
}
