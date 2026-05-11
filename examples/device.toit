// Copyright (c) 2026 Ekorau LLC
// Loads a JSON model from disk, starts RpcService on :8090, and drives the
// model's two inputs through a slow triangle-wave sweep so the Plotly Dash
// viz shows live term pertinences and centroid motion.
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
  task:: service.start
  drive-inputs model

drive-inputs model/FuzzyModel -> none:
  step := 0
  while true:
    model.crisp-input 0 (triangle-amplitude (step % 20))
    model.crisp-input 1 (triangle-amplitude ((step + 10) % 20))
    model.fuzzify
    sleep --ms=500
    step = step + 1

triangle-amplitude phase/int -> float:
  return (phase < 10 ? phase : 20 - phase).to-float
