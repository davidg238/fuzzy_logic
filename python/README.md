# fuzzy_lab — Python tooling for fuzzy_logic

Two console scripts:

- `fcl2json <input.fcl>` — convert FCL to JSON (writes to stdout or `--output`).
- `fuzzy-lab --connect ws://host:port` — Plotly Dash visualizer.

## Setup

```
uv sync --all-extras
uv run pytest
```
