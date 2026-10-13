# Cursor

## Server

Add to `~/.cursor/mcp.json`, or to `.cursor/mcp.json` inside a project:

```json
{
  "mcpServers": {
    "kubevela": {
      "command": "vela",
      "args": ["mcp"]
    },
    "kubernetes": {
      "command": "kubernetes-mcp-server",
      "args": ["--read-only"]
    }
  }
}
```

Add your observability server alongside, following its vendor's instructions. Pin the
versions listed in `pins/servers.yaml`.

## Skills

Cursor reads skills from its rules and skills locations; the exact directory has changed
between releases. Place the skill directories where your Cursor version documents, or
reference the `SKILL.md` files from a project rule. The procedure in each skill is plain
Markdown and works as a rule file unchanged.
