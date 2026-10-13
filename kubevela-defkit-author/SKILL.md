---
name: kubevela-defkit-author
description: Author KubeVela X-Definitions in Go with defkit, validate the generated CUE, render a sample Application against it, and deliver it by pull request. Use when the user wants a new ComponentDefinition, TraitDefinition, PolicyDefinition or WorkflowStepDefinition, or wants to port an existing CUE definition to Go.
license: Apache-2.0
metadata:
  version: 0.1.0
  kubevela: ">=1.11"
  kep: design/vela-cli/kep-vela-mcp.md
---

# Authoring capabilities with defkit

defkit is KubeVela's Go SDK for writing definitions. Go code compiles to the CUE the
controller evaluates; authors get a typed builder, unit tests and IDE support, and never
hand-write CUE. The loop you drive is: search the catalog, write Go, test, generate, vet,
render a sample, deliver by pull request. Every step has a deterministic check, and you do
not move to the next until the current one passes.

## Sequence

1. **Search the catalog first.** Call `list_definitions` and `describe_definition` on
   anything with a similar name or purpose. If an existing definition plus a trait covers
   most of the request, present that option before writing anything. Catalog sprawl is a
   platform cost; a new definition needs a reason that an existing one cannot meet.
2. **Scaffold.** For an addon, `vela addon init <name> --godef --components <list>
   --traits <list>` generates the module layout. For a standalone definition module use
   the defkit documentation's layout under `godef/`. Read the generated files before
   editing; the scaffold encodes the conventions.
3. **Write the definition in Go.** Use defkit's parameter builders for every parameter.
   Mark required parameters as required, give defaults where the platform has an opinion,
   and attach usage strings; they become the schema developers see. Keep the resource
   construction schema-agnostic as defkit intends; do not import Kubernetes API types to
   build output objects.
4. **Test in Go.** Write table-driven tests that render the definition with representative
   parameters and assert on the rendered objects. Run `go test ./...`. Fix failures before
   generating.
5. **Generate and vet the CUE.** Generate with the module's `make` target or the defkit
   command the scaffold provides, then run `vela def vet <file>.cue`. A vet failure is a
   bug in the Go, not in CUE; fix it at the source and regenerate.
6. **Render a sample Application.** Write a minimal Application that uses the definition
   and call `dryrun_application` with the generated CUE supplied as a local definition.
   Confirm the rendered objects, the defaults and the parameter schema a developer would
   see. Render at least one variant with optional parameters set.
7. **Check the schema the consumer will get.** Call `describe_definition` against the
   rendered definition where the tooling allows, or read the generated parameter block.
   Parameter names, types and usage strings are the contract; review them as such.
8. **Deliver by pull request.** Include the Go source, the generated CUE, the sample
   Application and the rendered output. Do not apply the definition to a shared control
   plane directly; the platform-engineer skill covers how a definition reaches clusters.

## Porting an existing CUE definition

Render the existing definition against two or three real Applications first and keep that
output as the golden result. Write the Go version, render the same Applications, and diff.
Differences are findings to resolve, not noise. Deliver only when the renders match or every
difference is explained in the pull request.

## Never

- Hand-edit generated CUE. Change the Go and regenerate.
- Skip `vela def vet` because the Go tests passed. Vet checks the artifact the controller
  will actually evaluate.
- Invent defkit APIs. If the builder you want does not exist in the version in use, say
  so and use the escape hatch defkit documents, with a comment explaining why.
- Create a definition without stating which existing definitions were considered.

## CLI fallback

| Step | CLI |
|---|---|
| Catalog search | `vela def list`, `vela show <name>` |
| Scaffold | `vela addon init <name> --godef --components <list> --traits <list>` |
| Vet | `vela def vet <file>.cue` |
| Render sample | `vela dry-run -f sample.yaml -d <generated>.cue --offline` |
| Inspect generated schema | `vela def get <name>` after `vela def apply` to a local or kind cluster, never to shared infrastructure |

The `No usable kubeconfig` message from `vela dry-run --offline` and `vela def vet` is
expected without a cluster. It only means external CUE packages were not loaded.
