// Copyright (c) 2026 Ekorau LLC
// Loads a JSON model from disk and starts RpcService on :8090. The Plotly
// Dash viz pushes crisp input values via POST /input and polls /state.
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
  service := RpcService model network --port=8090
  print "fuzzy_logic RpcService listening on :8090 (model=$model.name)"
  service.start
