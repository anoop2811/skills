# KubeVela skills

Agent skills, client setup templates and the evaluation suite for operating KubeVela
through AI assistants such as Claude Code, Codex, Cursor and Gemini CLI. This repository
pairs with `vela mcp`, the Model Context Protocol server proposed for the `vela` CLI in
[KEP: Vela MCP](https://github.com/kubevela/kubevela/blob/master/design/vela-cli/kep-vela-mcp.md).

A skill teaches an agent the order of operations and the stopping points. The MCP server
tells it what it can call. The two are designed together, but the skills here also work
today with the plain `vela` CLI: every tool a skill names has a CLI fallback listed in the
skill, so an agent that can run shell commands can follow the same procedure before
`vela mcp` ships.

## Status

`vela mcp` is a design proposal, not a released feature. Tool names in these skills follow
the KEP and may change during implementation. Until the server ships, agents use the CLI
fallbacks. The evaluation suite under `eval/` is specified but not yet implemented.

## Layout

```
kubevela-developer/          Compose, validate and deploy Applications
kubevela-sre/                Investigate incidents with vela, a Kubernetes MCP and an observability MCP
  servers/                   Per-server tool appendices (grafana, datadog, kubernetes)
kubevela-platform-engineer/  Change definitions safely, inventory clusters and addons
kubevela-defkit-author/      Author capabilities in Go with defkit, validate, render, deliver by PR
clients/                     Setup snippets for Claude Code, Codex, Cursor, Gemini CLI
pins/                        Third-party MCP server versions the skills were tested against
eval/                        Scenario definitions and the cross-model evaluation harness
scripts/                     Validation for skill files
```

Each skill is a directory with a `SKILL.md` on the
[agentskills.io](https://agentskills.io/specification) layout, so the same files load in
every client that supports the format.

## Installing a skill

Copy or symlink the skill directory into your client's skills location.

| Client | Location |
|---|---|
| Claude Code | `~/.claude/skills/<skill-name>/` for the user, or `.claude/skills/<skill-name>/` in a repository |
| Codex | `~/.codex/skills/<skill-name>/` |
| Cursor and Gemini CLI | See `clients/` for the current per-client path |

Example for Claude Code:

```sh
git clone https://github.com/kubevela/skills.git
ln -s "$PWD/skills/kubevela-developer" ~/.claude/skills/kubevela-developer
ln -s "$PWD/skills/kubevela-sre" ~/.claude/skills/kubevela-sre
```

Once `vela mcp setup` exists it will install the matching skills itself.

## The reference stack

For composing, validating and deploying Applications, `vela mcp` or the `vela` CLI is
enough. For incident work the SRE skill expects three servers loaded together:

| Server | Role | Access |
|---|---|---|
| `vela mcp` | Application composition, rendering, diff, status, managed resources | Read and plan by default; writes behind a flag |
| A Kubernetes MCP server | Nodes, namespaces, unmanaged resources | Read-only |
| The team's observability MCP | Metrics, traces, logs, alerts | As the vendor provides |

The boundary rule in every skill: anything an Application manages goes through vela;
reads of anything else go through the Kubernetes server; nothing is mutated through the
Kubernetes server in any documented configuration. `pins/servers.yaml` records the
third-party versions the skills were last checked against.

## Principles the skills enforce

1. KubeVela computes, the model explains. Risk classes, diffs and root-cause ordering come
   from deterministic output, never from the model's judgment.
2. Discover before drafting. Use only parameters a definition schema actually returns.
3. Render and diff before apply. Show the change set and risk class, then stop and ask.
4. The agent never resumes a gated workflow. A human does.
5. No new vocabulary. Skills use the words KubeVela users already know.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run `scripts/validate-skills.sh` before opening a
pull request; the same check runs in CI.

## License

Apache 2.0, the same as KubeVela.
