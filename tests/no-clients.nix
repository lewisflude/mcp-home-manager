# Test: Edge case - no clients (should work but not generate config files)
{
  services.mcp = {
    enable = true;
    clients = [ ];
  };
}
