# Kubernetes MCP server

Checked against: see `pins/servers.yaml` (`kubernetes`). The skills assume the server runs
in read-only or non-destructive mode, which `vela mcp setup` configures and which no
documented setup overrides.

Server: https://github.com/containers/kubernetes-mcp-server

## Boundary

Use this server only for things `explain_application` did not list as managed by the
Application: nodes, namespaces, resource quotas, an operator's own objects, an Ingress or
NetworkPolicy nobody rendered. For anything in the Application's resource tree, use
`get_managed_resource` from vela instead. Never use this server to change anything.

| Intent | Tool | Notes |
|---|---|---|
| Node pressure or scheduling failures | `nodes_list`, `events_list` | Filter events by the namespace and pods from the handles |
| Unmanaged objects in the namespace | `resources_list`, `resources_get` | Pass the cluster context from the handles when the server is multi-context |
| Pod state when vela's view is stale | `pods_list`, `pods_get` | Prefer `get_managed_resource` first; use this only to cross-check |
| Pod logs beyond vela's bounded tail | `pods_log` | Only when no observability server is loaded; otherwise use that server |
| Which context is active | `configuration_view` | Confirm you are looking at the cluster named in the handles |

Tool names vary slightly between releases of this server. If a name here does not exist,
list the server's tools and pick the equivalent rather than guessing arguments.
