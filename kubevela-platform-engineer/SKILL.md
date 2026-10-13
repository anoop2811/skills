---
name: kubevela-platform-engineer
description: Change KubeVela definitions, addons and cluster membership safely. Use when the user wants to modify a ComponentDefinition, TraitDefinition, PolicyDefinition or WorkflowStepDefinition, assess the impact of a definition change, enable or inspect addons, or inventory clusters.
license: Apache-2.0
metadata:
  version: 0.1.0
  kubevela: ">=1.11"
  kep: design/vela-cli/kep-vela-mcp.md
---

# Platform engineering on KubeVela

Definitions are shared contracts. Every Application that references one is a consumer, and
a change to the definition changes what all of them render on their next reconcile. Your
job is to make that blast radius visible before anything is applied, and to keep the
catalog from sprawling.

## Before changing a definition

1. **Find the consumers.** Call `find_definition_consumers` for the definition and
   revision. Report how many Applications reference it, in which namespaces and clusters,
   and whether they pin a revision or float on latest.
2. **Render a sample.** For a representative subset of consumers, call `diff_application`
   with the proposed definition supplied locally. Group the results: unchanged, modified,
   replaced. A replace means a resource will be recreated.
3. **Check restrictions.** Call `describe_definition` and read any namespace restriction
   the definition declares. Changing a restriction is an access-control change and must be
   presented as one.
4. **Present, then stop.** Give the consumer count, the grouped render results and the
   list of fields that changed in the rendered output. Ask how the user wants to proceed:
   a new definition version, an in-place change, or no change.
5. **Deliver through the team's path.** Definitions are usually delivered by pull request
   to a definitions repository or by an addon. Do not apply a definition to a production
   control plane directly unless the user explicitly says that is the team's practice.

## Before adding a definition

Search first. Call `list_definitions` and `describe_definition` on anything with a similar
name or purpose. If an existing definition plus a trait covers most of the request, say so
and ask whether to extend it instead. A catalog with two definitions that do nearly the
same thing is harder to support than one with a parameter. If the user decides to author a
new one in Go, switch to the `kubevela-defkit-author` skill.

## Addons and clusters

- `list_addons` and `list_clusters` are read-only. Use them to answer inventory questions
  and to check prerequisites before a definition change, for example whether the operator a
  definition renders objects for is installed on every target cluster.
- Enabling, upgrading or disabling an addon, and joining or detaching a cluster, are
  administrative actions that stay in the CLI. When the user asks for one, give the exact
  command and what it will do, and let them run it.

## Never

- Apply a definition change without a consumer count in front of the user.
- Describe a definition change as backward compatible from the schema alone. Render
  consumers; the rendered output is the compatibility test.
- Create a definition that duplicates an existing one without saying that it does.
- Change a namespace restriction without calling it an access-control change.

## CLI fallback

| Tool | CLI |
|---|---|
| `find_definition_consumers` | `kubectl get applications -A -o json \| jq -r '.items[] \| select(.spec.components[].type=="<name>") \| .metadata.namespace + "/" + .metadata.name'` (repeat with `.traits[].type` and `.spec.policies[].type` for traits and policies) |
| `describe_definition` | `vela show <name>`, `vela def get <name>` |
| `diff_application` with a local definition | `vela dry-run -f app.yaml -d <dir-with-proposed-definition>` and compare against `vela dry-run -f app.yaml` |
| `list_definitions` | `vela def list` |
| `list_addons`, `list_clusters` | `vela addon list`, `vela cluster list` |
| Definition revisions | `vela def get <name> --revision <n>`, `kubectl get definitionrevisions -n vela-system` |
