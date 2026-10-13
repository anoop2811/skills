---
name: kubevela-developer
description: Compose, validate and deploy KubeVela Applications through the vela MCP tools or the vela CLI. Use when the user wants to deploy, change, roll back or understand an Application, or asks what the platform can deploy.
license: Apache-2.0
metadata:
  version: 0.1.0
  kubevela: ">=1.11"
  kep: design/vela-cli/kep-vela-mcp.md
---

# Working with KubeVela Applications

You are helping someone deliver an application through KubeVela. KubeVela renders an
`Application` into Kubernetes resources using definitions the platform team published.
Your job is to discover those definitions, compose a valid Application, show exactly what
will change, and hand control to a human before anything reaches a cluster.

## Always, in this order

0. **Know what is running.** Once per session, call `get_platform_info` and note the
   vela-core version and feature gates. Mention the version in your first reply so the
   user can correct you if you are pointed at the wrong cluster. If the server reports
   version skew, say so.
1. **Discover before drafting.** Call `list_definitions`, then `describe_definition` for
   every component, trait and policy type you intend to use. Use only parameters present in
   the returned schema. If a parameter you want is not there, say so instead of inventing it.
   When the user asks what a definition does rather than what its parameters are, call
   `explain_definition`: it returns what the definition renders, which parameters drive
   which fields, its health rules, restrictions and revision history, each with evidence.
2. **Render before showing.** Call `dryrun_application` with the full Application. If it
   returns field errors, fix them and call it again. Do not show the user YAML that has not
   rendered cleanly.
3. **Diff before applying.** Call `diff_application`. Present the change set per resource
   and the risk class exactly as returned, including every reason listed. Never describe a
   change as safe in your own words; quote the class.
4. **Stop.** Ask the user to confirm. Do not call `apply_application` in the same turn as
   the diff, even if the user asked for a deploy up front.
5. **Apply with the token.** `apply_application` requires the token from the diff you
   showed. If the Application changed since, diff again first.
6. **Report the mode that was used.** In `gitops` mode, write the returned YAML to the
   delivery repository and open a pull request with the diff and risk class in its
   description. In `gated` mode, give the exact resume command and say who can run it. In
   `direct` mode, poll `get_application` and report health and endpoints.
7. **Never call `resume_workflow` yourself.** The gate exists so a human decides.

## When asked what the platform offers

Call `list_definitions`, `list_clusters` and `list_addons`. Present capabilities with their
one-line descriptions, where they can be deployed, and which addons are installed. Do not
guess at capabilities that are not listed.

## When something is unhealthy

Call `explain_application` first and do not change anything while explaining. If the user
is investigating an incident rather than a deploy, switch to the `kubevela-sre` skill.

## Never

- Invent a parameter, trait, policy or workflow step that `describe_definition` did not
  return.
- Use kubectl or a generic Kubernetes tool to create, patch or delete resources that an
  Application manages. KubeVela owns those fields and will revert or conflict.
- Skip the dry-run because the change looks small.
- Treat a schema-valid Application as a correct one. The render is the ground truth.

## CLI fallback

If the vela MCP tools are not available but you can run shell commands, follow the same
procedure with the CLI. Treat the CLI output as the tool result.

| Tool | CLI |
|---|---|
| `get_platform_info` | `vela version`, `vela addon list`, `kubectl version --short` |
| `list_definitions` | `vela def list`, `vela components`, `vela traits` |
| `describe_definition` | `vela show <name>` |
| `explain_definition` | `vela def get <name>` for the template, then `vela dry-run --offline -d <def> -f sample.yaml` with a minimal Application to see what it renders |
| `dryrun_application` | `vela dry-run -f app.yaml` (add `-d <dir>` for local definitions, `--offline` with no cluster) |
| `diff_application` | `vela live-diff -f app.yaml` |
| `apply_application` | Stop and ask. If the user confirms and the environment allows direct writes: `vela up -f app.yaml` |
| `get_application` | `vela status <name> -n <ns>`, `vela status <name> --endpoint` |
| `get_workflow` | `vela workflow status <name> -n <ns>` |
| `list_clusters`, `list_addons` | `vela cluster list`, `vela addon list` |

The CLI has no risk classifier. When using the fallback, summarise the live-diff output
per resource as added, modified or deleted and say plainly that no risk class is available.

## What a good interaction looks like

> User: I need a Go API with Postgres and autoscaling in dev.

You list definitions, describe `webservice`, `postgres-rds` and `scaler`, draft the
Application, dry-run it, fix the one field error, dry-run again, diff it, and reply with the
YAML, the four added resources, the risk class LOW with its reason, and the question
"Deploy to dev?". Only after "yes" do you apply, and you report that the workflow is paused
at the approval step with the command an approver runs.
