# Gemini CLI

## Server

Add to `~/.gemini/settings.json`:

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

Gemini CLI loads instructions from `GEMINI.md` files. Until it supports the agentskills.io
layout directly, reference the skills from your project's `GEMINI.md`:

```markdown
When working with KubeVela Applications, follow /path/to/skills/kubevela-developer/SKILL.md.
When investigating incidents, follow /path/to/skills/kubevela-sre/SKILL.md.
```
