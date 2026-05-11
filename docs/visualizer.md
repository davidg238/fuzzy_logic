# Visualizer (`fuzzy-lab`)

`fuzzy-lab` is a Plotly Dash app that talks to a running [`RpcService`](rpc-service.md). It renders the model topology, lets you drive crisp inputs with sliders, and hot-swaps the engine's model from any `.fcl` in your `fcl/` directory.

It's an authoring + inspection tool — not part of the Toit package. Lives in `python/fuzzy_lab/viz/`.

## Setup

```bash
cd python
uv sync --all-extras
```

`uv sync` installs Dash, Plotly, httpx, Lark, and pytest. The first run pulls a few hundred MB of packages and takes about a minute; subsequent runs reuse the cached venv.

## Running

```bash
# Engine in one shell:
jag toit run examples/device.toit
# fuzzy_logic RpcService listening on :8090 (model=tipper)

# Visualizer in another shell:
cd python
uv run fuzzy-lab --connect http://127.0.0.1:8090
# Dash app on http://127.0.0.1:8050/
```

Open `http://127.0.0.1:8050/` in a browser.

### CLI flags

| Flag | Default | Purpose |
|---|---|---|
| `--connect` | `http://127.0.0.1:8080` | Base URL of the `RpcService` |
| `--port` | `8050` | Dash app port |
| `--poll-ms` | `500` | Interval for `GET /state` polls |
| `--fcl-dir` | `<repo>/fcl` | Directory globbed (non-recursively) for `*.fcl` in the file picker |

If the engine is reachable but on a different port — e.g., `:8090` like `examples/device.toit` uses — pass `--connect http://127.0.0.1:8090`. For a device on the LAN: `--connect http://192.168.0.130:8090`.

## What you see

```
┌───────────────────────────────────────────────────────────────┐
│ tipper                       [ choose .fcl ▾ ]                │
├───────────────────────────────────────────────────────────────┤
│ Inputs                                                        │
│  ┌─ service ──────────────┐  ┌─ food ──────────────────────┐  │
│  │ poor good excellent    │  │ rancid delicious            │  │
│  │   [membership figure]  │  │   [membership figure]       │  │
│  │   ───●──── slider ──── │  │   ──────●──── slider ────── │  │
│  └────────────────────────┘  └─────────────────────────────┘  │
├───────────────────────────────────────────────────────────────┤
│ Rules                                                         │
│  R1: service is poor OR food is rancid → tip is cheap   [fired] │
│  R2: service is good                   → tip is average        │
│  ...                                                          │
├───────────────────────────────────────────────────────────────┤
│ Outputs                                                       │
│  ┌─ tip ─────────────────────────────────────────────────┐    │
│  │  [composition figure with COG marker]  crisp = 14.8   │    │
│  └───────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

- **File picker** (top right): lists every `*.fcl` directly under `--fcl-dir`. Picking one runs `fcl2json` in-process, `POST /model`s the result, and re-renders. Errors render inline in red without losing the current model.
- **Input panels**: one per input variable. The figure shows each term's membership function color-coded; the slider drives `POST /input` on every drag.
- **Rules row**: lists the rules with synthesized human-readable names; "fired" indicators flip live as inputs change.
- **Output panels**: stacked membership functions truncated to current pertinence; the centroid (crisp output value) is marked.

Term names in the input/output panels match the colors of their polygons.

## Hot-swap loop

The picker re-parses the chosen `.fcl` through `fcl2json` every time you select it. So the iteration loop is:

1. Edit `fcl/your-model.fcl`.
2. In the viz, re-select the file from the dropdown.
3. New topology is in place; sliders still work, polling resumes.

No need to restart anything. If your edit introduces an unsupported feature, the parser error renders inline and the previous model stays loaded.

## Known limitations

- **View + slider only.** You can change crisp inputs and hot-swap the whole model, but you cannot drag membership-function vertices to edit shapes in place. To change a shape, edit the `.fcl` and re-select.
- **HTTP polling, not WebSocket.** The page polls `GET /state` every `--poll-ms` milliseconds (default 500). Plenty fast for human-driven interaction; not designed for high-frequency telemetry.
- **No persistence.** Closing the browser loses the current crisp inputs; on next open the engine state is whatever it was when you reconnected.

## Troubleshooting

- **`ConnectionRefusedError` on startup** — the engine isn't running. Start `examples/device.toit` (or your equivalent) first.
- **Dropdown is empty** — `--fcl-dir` points somewhere with no `*.fcl` files. Default is the repo's `fcl/`.
- **All sliders snap to the left** — the model on the engine doesn't match the slider ranges. The viz uses `min(term.a)`/`max(term.d)` per input from `GET /model`; if your model has weird negative-bound terms (like `container-crane`'s `too_far`), the slider may not cover the full meaningful range.

## Tests

```bash
cd python && uv run pytest -k viz
```

Covers the figure builders (`plots.py`) and the HTTP client (`rpc.py`). The Dash UI itself is exercised manually.
