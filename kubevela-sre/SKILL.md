---
name: kubevela-sre
description: Investigate incidents on KubeVela Applications using the vela MCP tools together with the team's observability MCP server and a read-only Kubernetes MCP server. Use for alerts, degraded or unhealthy Applications, latency or error questions, stuck workflows, and rollbacks.
license: Apache-2.0
metadata:
  version: 0.1.0
  kubevela: ">=1.11"
  kep: design/vela-cli/kep-vela-mcp.md
---

# Incident investigation on KubeVela

Three servers share this work. KubeVela knows how the Application is composed, which
resources it manages, which component depends on which, and when each revision was
applied. The observability server holds the evidence over time. The Kubernetes server
covers the cluster outside what KubeVela manages. Your job is to move between them without
retyping or guessing any identifier, and to change nothing while you investigate.

## Sequence

0. **Know what is running.** Once per session, call `get_platform_info` and keep the
   result: vela-core version, CLI version, Kubernetes version per cluster, feature gates,
   and any version-skew warning. Every report you write names these. If the server flags a
   mismatch, say so before anything else; version skew is a common root cause.
1. **Explain first.** Call `explain_application` for the affected Application. Read the
   root candidates, the impact list, the blocked workflow step, and whether traffic
   changed. Read the `evidence` list and the `unknowns` list. Take the **handles** from the
   response: `cluster`, `namespace`, `pods`, `labels`, `revision`, `appliedAt`, `window`,
   `traceService`, `logSelector`. From here on, every query uses these values verbatim.
2. **Metrics for the window.** Query request latency and error rate for the handles'
   labels over the handles' window. The server-specific tool is in `servers/`.
3. **Traces for the failing path.** Search error traces for `traceService` in the window.
   Note the top failing span and what it calls.
4. **Logs behind the span.** Query logs with `logSelector`, filtered by the failing span's
   target, from `window.start`. If `get_logs` from vela returned a bounded tail and said
   more is available, go to the observability server rather than paging.
5. **Managed resources through vela, everything else through Kubernetes.** If a resource
   KubeVela manages needs a closer look, call `get_managed_resource`. Use the Kubernetes
   server only for nodes, namespaces, quotas and objects that `explain_application` did
   not list.
6. **Correlate.** Compare the revision's `appliedAt` with the first change in the metrics.
   Say whether they align, and what in the diff between revisions explains it.
7. **Propose, do not perform, the remedy.** For a rollback, call `get_application` for the
   previous revision and `diff_application` with its spec as the proposed change. Quote
   the risk class and reasons. Stop and ask before `apply_application`. Rollbacks go through
   the same gate as any other change.

## Reporting

Lead with the cause in one sentence, then the evidence in the order you gathered it, then
the proposed remedy with its risk class. Every factual claim points at an object: the
resource, the field or condition, and its timestamp, as returned in `evidence`. Repeat the
server's `unknowns` as unknowns; do not fill them in. State the versions from
`get_platform_info` and the `observedAt` time of the status you relied on. If any response
had `truncated: true`, say what was cut. Say what you did not check.

## Never

- Mutate anything while investigating, from any server.
- Use the Kubernetes server to read or change a resource that `explain_application`
  listed as managed. Use vela for those.
- Describe telemetry you did not query. If a server is not loaded, say that the evidence
  is unavailable rather than inferring it.
- Resume, suspend or terminate a workflow without being asked by the user.

## Server appendices

Concrete tool names for the third-party servers are kept out of this file so they can
change without rewriting the procedure:

- `servers/grafana.md` for the Grafana MCP server
- `servers/datadog.md` for the Datadog MCP server
- `servers/kubernetes.md` for the Kubernetes MCP server

Each appendix names the version it was checked against; `pins/servers.yaml` in the
repository root is the source of truth.

## CLI fallback

| Tool | CLI |
|---|---|
| `get_platform_info` | `vela version`, `kubectl -n vela-system get deploy kubevela-vela-core -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}{.spec.template.spec.containers[0].args}'`, `kubectl version --short` per cluster, `vela addon list` |
| `explain_application` | `vela status <name> -n <ns> --tree --detail`, then `kubectl get events` for each unhealthy resource it lists |
| `get_managed_resource` | `vela status --tree` to find the object, then `kubectl get <kind> <name> -n <ns> -o yaml` in the cluster it names |
| `get_workflow` | `vela workflow status <name> -n <ns>` |
| `get_logs` | `vela logs <name> -n <ns>` |
| `diff_application` | `vela live-diff -f previous-revision.yaml` |

Without `explain_application` you must build the handles yourself: pods and labels from
`vela status --tree --detail`, the window from the revision timestamp in
`vela revision list <name>`. State that these were assembled by hand.
