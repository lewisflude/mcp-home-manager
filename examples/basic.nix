# Basic MCP Configuration Example
#
# This example shows the minimal configuration needed to enable MCP servers.
# Default servers (memory, git, time, sqlite, everything) are enabled automatically.

{
  services.mcp = {
    enable = true;

    # That's it! Default servers are enabled automatically and configured for:
    # - Claude Desktop (~/.config/claude/claude_desktop_config.json on Linux)
    # - Cursor (~/.cursor/mcp.json)
  };
}
