# Test: Default configuration with both clients and default secret path
{
  services.mcp = {
    enable = true;
    # Uses defaults:
    # secretsPath = "/run/secrets";
    # clients = [ "cursor" "claude-desktop" ];
  };
}
