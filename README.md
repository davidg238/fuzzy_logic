# fuzzy_logic

A Toit fuzzy inference engine for ESP32 and host environments. Models can be declared inline as a Toit `Map`, as JSON (string constant or file on flash), or in FCL (Fuzzy Control Language). The engine evaluates them with closed-form centroid math, and (optionally) exposes a live HTTP API for a Python Plotly Dash visualizer.

Originally an adaptation of [eFLL — Embedded Fuzzy Logic Library](https://github.com/zerokol/eFLL).

## Install

In your Toit project's `package.yaml`:

```yaml
dependencies:
  fuzzy-logic:
    url: github.com/<owner>/fuzzy_logic
    version: ^0.8.0
```

Then `jag toit pkg install`.

## A taste

```toit
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model

MODEL ::= {
  "name": "tipper",
  "inputs":  [{"name":"service","terms":[{"name":"good","a":1,"b":4,"c":6,"d":9}]}],
  "outputs": [{"name":"tip",    "terms":[{"name":"average","a":10,"b":15,"c":15,"d":20}]}],
  "rules":   [{"if":{"op":"is","var":"service","term":"good"},
              "then":[{"var":"tip","term":"average"}]}],
}

main:
  model := load-model MODEL
  model.crisp-input 0 5.0
  model.fuzzify
  print "tip = $(%.2f model.defuzzify 0)"
```

The engine + JSON loader pull in no HTTP, no WebSocket, no file-system dependencies. See [`examples/`](examples/) for working models across deployment patterns.

## Documentation

| | |
|---|---|
| Five-minute walkthrough | [docs/getting-started.md](docs/getting-started.md) |
| **Deploy to ESP32** | [docs/esp32-deployment.md](docs/esp32-deployment.md) |
| Engine API + concepts | [docs/engine.md](docs/engine.md) |
| Three ways to author a model | [docs/models.md](docs/models.md) |
| FCL grammar + error contract | [docs/fcl.md](docs/fcl.md) |
| HTTP API (`RpcService`) | [docs/rpc-service.md](docs/rpc-service.md) |
| Plotly Dash visualizer | [docs/visualizer.md](docs/visualizer.md) |
| Catalog of bundled `.fcl` files | [fcl/index.md](fcl/index.md) |

## Versioning

Semantic-ish. `0.8.0` makes `fcl2json` strict about unsupported FCL semantics (breaking change for any `.fcl` declaring non-default `AND`/`OR`/`ACT`/`ACCU`/`METHOD`). `0.7.0` introduced the JSON loader, RPC service, and Python tooling. `0.6.x` removed the geometry helpers from the public API.

## License

See `LICENSE`. Engine math derives from work originally licensed under `LICENSE_ALVES` (eFLL) and `LICENSE_Toitware`; both upstream licenses are preserved at the repository root.
