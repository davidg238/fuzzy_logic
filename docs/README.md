# Documentation

`fuzzy_logic` is a Toit fuzzy inference engine that runs on ESP32 hardware and on a host (Linux/macOS). Models can be declared inline as a Toit `Map`, as JSON (string constant or file on flash), or in FCL (Fuzzy Control Language) — see [models.md](models.md). The engine evaluates them with closed-form centroid math, and optionally exposes an HTTP API for a Python Plotly Dash visualizer.

## Where to start

| If you want to… | Read |
|---|---|
| See it run in under five minutes | [getting-started.md](getting-started.md) |
| **Deploy a fuzzy controller to an ESP32** | [esp32-deployment.md](esp32-deployment.md) |
| Author a model (inline / JSON / FCL) | [models.md](models.md) |
| Understand the Toit engine API | [engine.md](engine.md) |
| Write `.fcl` files for the parser | [fcl.md](fcl.md) |
| Drive the engine remotely over HTTP | [rpc-service.md](rpc-service.md) |
| Use the Plotly Dash visualizer | [visualizer.md](visualizer.md) |

## What it does

A *fuzzy inference system* maps crisp numeric inputs to crisp numeric outputs through:

1. **Fuzzification** — each input value is matched against membership functions ("how *cold* is 18°C? 0.7 cold, 0.3 cool"),
2. **Rule evaluation** — antecedents (combinations of fuzzified inputs) activate consequents (output membership functions),
3. **Defuzzification** — activated output sets are combined and reduced to a single crisp value via the center-of-gravity (COG) method.

The engine targets embedded use: inference uses closed-form centroid math (no polygon vertex construction per cycle — see [engine.md](engine.md#closed-form-centroid-math)), shapes are stored as four floats `(a, b, c, d)` per term, and the engine + JSON loader have no HTTP / WebSocket / file-system dependencies.

## Layering

Three import surfaces, each opt-in:

```
import fuzzy-logic show *                       # core engine only — zero external deps
import fuzzy-logic.json-loader show load-model  # add JSON Map→FuzzyModel — still no http
import fuzzy-logic.rpc-service show RpcService  # add HTTP API — pulls in pkg-http
```

Detail: see [engine.md](engine.md#layering).
