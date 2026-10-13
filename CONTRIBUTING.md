# Contributing

## What belongs here

- Skills that teach an agent how to operate KubeVela: the sequence, the stopping points,
  the boundaries between servers, and the CLI fallback.
- Per-server appendices with the concrete tool names a skill needs, kept separate from
  the skill body so a third-party server can change without rewriting the procedure.
- Client setup snippets, the version-pin table, and the evaluation suite.

What does not belong here: the `vela mcp` server itself, which lives in
kubevela/kubevela, and anything that embeds credentials or cluster-specific values.

## Adding or changing a skill

1. One directory per skill, named `kubevela-<role>`, containing `SKILL.md` and optionally
   `servers/`, `references/` or `scripts/`.
2. Frontmatter must have `name` equal to the directory name and a `description` that says
   when the skill applies. Keep `SKILL.md` under 500 lines; move long material into
   `references/`.
3. Every tool the skill names must have a CLI fallback row, so the skill works before the
   server ships and for agents that only have a shell.
4. Write procedures as numbered steps with explicit stopping points. State what the agent
   must never do. Avoid adjectives; prefer the exact command or tool.
5. Run `scripts/validate-skills.sh` locally. CI runs the same check.

## Changing a server appendix or the pins

When a third-party server's tool names change, update the appendix and the `checked` date
in `pins/servers.yaml` in the same pull request. Once the evaluation suite exists, a pin
moves only when the suite passes against the new version.

## Style

Plain English, short sentences, no marketing words. The reader is an agent that will
follow the text literally and a maintainer who will have to debug what it did.
