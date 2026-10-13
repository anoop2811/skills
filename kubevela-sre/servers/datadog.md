# Datadog MCP server

Checked against: see `pins/servers.yaml` (`datadog`). Tool names below are from the
server's published tool list and must be re-verified whenever the pin moves.

Server: https://docs.datadoghq.com/bits_ai/mcp_server/

| Intent in the SRE sequence | Tool | Notes |
|---|---|---|
| Metrics for the window (step 2) | `get_datadog_metric` | Query the service's latency and error-rate metrics scoped by the handles' tags. KubeVela labels usually arrive as tags such as `kube_app_oam_dev_component:<component>` through the Kubernetes integration; confirm the tag name with `get_datadog_metric_context` first |
| Traces (step 3) | `search_datadog_spans`, `aggregate_spans`, `get_datadog_trace` | Search spans for `service:<traceService>` with `status:error` in the window, aggregate by resource to find the top failing endpoint, then fetch one trace |
| Logs behind the span (step 4) | `search_datadog_logs`, `analyze_datadog_logs` | Build the query from the handles: `kube_namespace:<namespace> pod_name:(<pods>)` plus a text filter for the failing span's target |
| What fired | `search_datadog_monitors`, `search_datadog_events` | Confirm the alert and its first trigger time; use it to tighten the window |
| Incident context | `search_datadog_incidents`, `get_datadog_incident` | Only if an incident was declared |
| Recent changes | `get_change_stories` | Correlate with the revision's `appliedAt` |

Time windows: pass the handles' `window.start` and `window.end` explicitly. Do not rely on
server defaults, which are usually the last 15 minutes and will miss the apply time.
