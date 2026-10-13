# Evaluation suite

Status: specified, not implemented. This directory will hold the harness that runs the
scenarios below against several model families and scores the tool-call sequence against
what the skills prescribe. The KEP sets the release bar at 90 percent on three model
families, and the suite is how tool descriptions and skill wording get edited: in response
to measured failures, not to taste.

## Planned layout

```
eval/
  scenarios/        One file per scenario: prompt, fixture cluster state, expected tool sequence, pass criteria
  fixtures/         velad-based cluster states the scenarios run against
  stub-o11y-mcp/    A stub observability MCP server that serves canned metrics, traces and logs
                    keyed by the labels and window it receives, and asserts the queries carry
                    the handles vela emitted
  harness/          Runs a scenario through a generic MCP client against a chosen model, records
                    the tool calls, scores them, and reports wrong-server calls
```

## Scenarios

| Scenario | Skill | Pass criteria |
|---|---|---|
| Compose and gated deploy | developer | Discover, dry-run until clean, diff, stop, apply gated; no invented parameters; no resume call |
| Explain a degraded Application | sre | explain_application first; no mutation; root component named correctly on the fixture |
| Incident across the reference stack | sre | Handles from explain reused verbatim in every observability query; zero manual lookups; wrong-server calls under 5 percent |
| Author a capability with defkit | defkit-author | Catalog searched first; go test, def vet and dry-run with local definition all run before delivery is proposed |
| Impact of a definition change | platform-engineer | Consumer count presented before any change; sample renders grouped as unchanged, modified, replaced |
| What does the platform offer | developer | Only listed definitions, clusters and addons reported; no guessed capabilities |

Each scenario runs twice: with vela alone, and with the Kubernetes and stub observability
servers co-loaded, so tool selection is tested under realistic ambiguity.

## Scoring

- Sequence correctness: required calls present, in order, with the stopping points honoured.
- Wrong-server calls: any Kubernetes-server call for a managed resource, or any
  observability query that does not carry the emitted handles.
- Forbidden calls: resume_workflow, any mutation during an investigation, any write without
  a preceding diff token.

Results are published per release in this directory so description changes can be judged
against the previous run.
