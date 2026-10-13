# Client setup

Snippets for connecting each client to `vela mcp` and loading the skills. `vela mcp setup`
will write these for you once it ships; until then, copy the snippet for your client.

`vela mcp` is not yet released. The snippets reference it so they are correct when it
lands. Today, install the skills alone and let the agent use the CLI fallbacks each skill
lists.

| Client | File |
|---|---|
| Claude Code | `claude-code.md` |
| Codex | `codex.md` |
| Cursor | `cursor.md` |
| Gemini CLI | `gemini-cli.md` |

All snippets start the server read-only. Add `--allow-write` only for environments where
the mode policy has been reviewed, and never add `--allow-resume` outside a single-user
sandbox. The flags follow the KEP; check `vela mcp --help` for the released set.
