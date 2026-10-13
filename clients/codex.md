# Codex

## Server

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.kubevela]
command = "vela"
args = ["mcp"]

[mcp_servers.kubernetes]
command = "kubernetes-mcp-server"
args = ["--read-only"]
```

Add your observability server alongside, following its vendor's instructions. Pin the
versions listed in `pins/servers.yaml`.

## Skills

Copy or symlink the skill directories into `~/.codex/skills/`:

```sh
ln -s /path/to/skills/kubevela-developer ~/.codex/skills/kubevela-developer
ln -s /path/to/skills/kubevela-sre ~/.codex/skills/kubevela-sre
```

Check the Codex documentation for the current skills location if this path has moved.
