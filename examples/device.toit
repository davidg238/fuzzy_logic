// Copyright (c) 2026 Ekorau LLC
// Loads a JSON model from disk and starts RpcService on :8080.
// On host: smoke target for the Plotly Dash viz.
// On device: replace host.file with assets/ and provide a wifi net.Interface.

import encoding.json
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import fuzzy-logic.rpc-service show RpcService
import host.file as file
import net

MODEL-PATH ::= "fcl/generated/tipper.json"

main:
  text := (file.read-contents MODEL-PATH).to-string
  model := load-model (json.parse text)
  network := net.open
  service := RpcService model network --port=8080
  print "fuzzy_logic RpcService listening on :8080 (model=$model.name)"
  service.start
