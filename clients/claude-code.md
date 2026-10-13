# Claude Code

## Server

Add to `~/.claude.json` under `mcpServers`, or run
`claude mcp add kubevela -- vela mcp`:

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

Verify inside a session with `/mcp`.

## Skills

Symlink or copy the skill directories into `~/.claude/skills/` for every project, or into
`.claude/skills/` inside a repository to scope them to it:

```sh
ln -s /path/to/skills/kubevela-developer ~/.claude/skills/kubevela-developer
ln -s /path/to/skills/kubevela-sre ~/.claude/skills/kubevela-sre
ln -s /path/to/skills/kubevela-platform-engineer ~/.claude/skills/kubevela-platform-engineer
ln -s /path/to/skills/kubevela-defkit-author ~/.claude/skills/kubevela-defkit-author
```

Claude Code picks skills up on the next session start.
