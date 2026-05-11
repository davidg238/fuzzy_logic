# RPC service

`fuzzy-logic.rpc-service` exposes a `FuzzyModel` over HTTP. It's an opt-in import — engine-only consumers don't pay for `pkg-http`. The Python visualizer ([visualizer.md](visualizer.md)) speaks this protocol; you can also drive it from `curl` or any HTTP client.

## When to use it

- You want the visualizer to drive a model running on an ESP32.
- You want to inspect / poke a deployed model without reflashing.
- You're running headless tests of a model and want to script `crisp-input` / `defuzzify` from outside Toit.

If you only need batch inference inside your Toit program, **don't** import this — use the engine directly.

## Starting the service

```toit
import net
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import fuzzy-logic.rpc-service show RpcService

main:
  model := load-model MODEL
  network := net.open
  service := RpcService model network --port=8090
  print "fuzzy_logic RpcService listening on :$service.port (model=$model.name)"
  service.start    // blocks; runs the HTTP loop until cancelled
```

`--port=8090` is the convention `examples/device.toit` uses (`:8080` collides with Jetty / other dev tools on some workstations). The `network` argument is whatever `net.open` returns on your platform — host (Linux/macOS) or ESP32 WiFi.

## Endpoints

| Path | Method | Body | Returns |
|---|---|---|---|
| `/model` | `GET` | — | full model topology as JSON (`{name, defuzz_method, inputs, outputs, rules}`) |
| `/model` | `POST` | a full model JSON document | `{"ok": true}` — hot-swaps the in-memory model |
| `/state` | `GET` | — | per-term pertinences + current crisp inputs + defuzzified outputs |
| `/input` | `POST` | `{"var": "<name>", "value": <number>}` | `{"ok": true}` — sets one crisp input and re-runs `fuzzify` |

The service has no `POST /term` (per-term edit) and no WebSocket: the visualizer drives interactivity by polling `/state` (default 500 ms) plus `POST /input` on slider changes. Hot-swapping a different model is done by re-running `fcl2json` and `POST /model`-ing the new JSON.

## State format

`GET /state` returns the live runtime data — distinct from `/model`, which is the topology. Shape:

```json
{
  "name": "tipper",
  "inputs": [
    {
      "name": "service",
      "crisp": 5.0,
      "terms": [
        {"name": "poor",      "pertinence": 0.0},
        {"name": "good",      "pertinence": 1.0},
        {"name": "excellent", "pertinence": 0.0}
      ]
    }
  ],
  "outputs": [
    {
      "name": "tip",
      "crisp_out": 15.0,
      "terms": [
        {"name": "cheap",    "pertinence": 0.0},
        {"name": "average",  "pertinence": 1.0},
        {"name": "generous", "pertinence": 0.0}
      ]
    }
  ],
  "rules": [
    {"name": "R2", "fired": true},
    {"name": "R1", "fired": false},
    {"name": "R3", "fired": false}
  ]
}
```

A rule is "fired" when its antecedent power is greater than `0.0`. `crisp_out` is the result of `defuzzify` over the current pertinences.

## Driving it from curl

```bash
# Read topology:
curl -s http://127.0.0.1:8090/model | jq .

# Set an input and read state in one round-trip:
curl -s -XPOST http://127.0.0.1:8090/input \
     -H 'content-type: application/json' \
     -d '{"var":"service","value":5.0}'
curl -s http://127.0.0.1:8090/state | jq .outputs[0].crisp_out
```

## Errors

- Unknown route → `404`.
- Malformed JSON body → `400` with the parser's message.
- `POST /model` with a body that fails `load-model` validation → `400`; the previous model stays loaded (the swap is transactional).
- `POST /input` referencing an unknown `var` → `400`.

The service does not authenticate. Run it on a trusted network only, or front it with a reverse proxy.

## Footprint

Importing `fuzzy-logic.rpc-service` pulls in `pkg-http`. It does **not** pull in `pkg-host` — file I/O happens in your `main`, not in the service. See [esp32-deployment.md#sizing-footprint-by-pattern](esp32-deployment.md#sizing-footprint-by-pattern) for the dependency matrix.

## Related

- [visualizer.md](visualizer.md) — the Plotly Dash app that drives this API.
- [esp32-deployment.md](esp32-deployment.md) — how to start the service on hardware.
