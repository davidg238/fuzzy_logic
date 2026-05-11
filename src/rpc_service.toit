// Copyright (c) 2026 Ekorau LLC

import encoding.json
import http
import net

import .fuzzy-model show FuzzyModel

/**
Opt-in RPC layer over $FuzzyModel. Importing this module pulls in
http + encoding.json — engine consumers that don't need RPC should
import only fuzzy-logic.

Endpoints (Plan B v1):

| Path     | Method | Body          | Response               |
|----------|--------|---------------|------------------------|
| /model   | GET    |               | current model topology |
| /state   | GET    |               | model.serialize-state  |
| /input   | POST   | {var, value}  | { "ok": true }         |

Device + host run the same service; only the net.Interface differs.
*/
class RpcService:
  model_/FuzzyModel
  net_/net.Interface
  port/int

  constructor model/FuzzyModel network/net.Interface --port=8080:
    model_ = model
    net_ = network
    this.port = port

  start -> none:
    server := http.Server --max-tasks=4
    server.listen net_ port:: | request/http.RequestIncoming writer/http.ResponseWriter |
      handle_ request writer

  handle_ request/http.RequestIncoming writer/http.ResponseWriter -> none:
    method := request.method
    resource := request.query.resource
    if method == "GET" and resource == "/model":
      respond-json_ writer (model-topology_)
      return
    if method == "GET" and resource == "/state":
      respond-json_ writer model_.serialize-state
      return
    if method == "POST" and resource == "/input":
      handle-input_ request writer
      return
    respond-error_ writer 404 "unknown route $method $resource"

  handle-input_ request/http.RequestIncoming writer/http.ResponseWriter -> none:
    body := json.decode-stream request.body
    var-name := body["var"]
    value := body["value"]
    input-names := model_.inputs.map: | v | v.name
    if not (input-names.contains var-name):
      respond-error_ writer 404 "unknown var '$var-name'"
      return
    model_.crisp-inputs-named var-name value.to-float
    model_.fuzzify
    respond-json_ writer {"ok": true}

  model-topology_ -> Map:
    inputs := model_.inputs.map: | v | {"name": v.name,
        "terms": v.fsets.map: | s | {"name": s.name,
            "a": s.test-a, "b": s.test-b, "c": s.test-c, "d": s.test-d}}
    outputs := model_.outputs.map: | v | {"name": v.name,
        "terms": v.fsets.map: | s | {"name": s.name,
            "a": s.test-a, "b": s.test-b, "c": s.test-c, "d": s.test-d}}
    rules := model_.rules.map: | r | {"name": r.name, "weight": r.weight}
    return {"name": model_.name, "inputs": inputs, "outputs": outputs, "rules": rules}

  respond-json_ writer/http.ResponseWriter body/any -> none:
    writer.headers.set "Content-Type" "application/json"
    writer.out.write (json.encode body)

  respond-error_ writer/http.ResponseWriter status/int message/string -> none:
    writer.headers.set "Content-Type" "application/json"
    writer.write-headers status
    writer.out.write (json.encode {"error": message})
