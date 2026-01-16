# Test: Cursor client only with custom secret path
{
  services.mcp = {
    enable = true;
    secretsPath = "/run/secrets-for-users";
    clients = [ "cursor" ];
  };
}
