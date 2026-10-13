# Grafana MCP server

Checked against: see `pins/servers.yaml` (`grafana`). Tool names below are from the
upstream server's tool list and must be re-verified whenever the pin moves.

Server: https://github.com/grafana/mcp-grafana

| Intent in the SRE sequence | Tool | Notes |
|---|---|---|
| Find the Prometheus and Loki datasources | `list_datasources` | Do this once per session and remember the UIDs |
| Metrics for the window (step 2) | `query_prometheus` | Range query. Build the selector from the handles' labels, for example `{app_oam_dev_component="<component>", cluster="<cluster>"}`. Use `window.start` and `window.end` from the handles |
| Logs behind the span (step 4) | `query_loki_logs` | Use the handles' `logSelector` as the stream selector; add a line filter for the failing span's target |
| Log volume before reading lines | `query_loki_stats` | Cheap check that the selector matches something in the window |
| Traces (step 3) | `query_tempo`, where available | Search by `traceService` and error status within the window. If the server version has no Tempo tool, say traces are unavailable |
| Alert context | `list_alert_rules`, `get_alert_rule_by_uid` | Only to confirm what fired and when |
| Dashboards | `search_dashboards` | For links in the report, not for evidence |

Label naming: KubeVela stamps `app.oam.dev/name`, `app.oam.dev/component` and
`app.oam.dev/revision` on rendered resources. Prometheus relabels dots and slashes to
underscores, so the metric label is usually `app_oam_dev_component`. Check with one
`query_prometheus` instant query before building the range query.
