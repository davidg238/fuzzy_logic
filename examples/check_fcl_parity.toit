// Copyright (c) 2026 Ekorau LLC
// Confirms that each fcl/generated/<name>.json model behaves identically to
// the corresponding hand-coded model in examples/models.toit at fixed input
// vectors. Run after authoring or regenerating an FCL file:
//
//   jag toit run examples/check_fcl_parity.toit
//
// Lives in examples/ (not tests/) so it can use host.file without adding
// a new dependency to the engine's package.yaml.

import encoding.json
import host.file as file
import fuzzy-logic show *
import fuzzy-logic.json-loader show load-model
import .models show *

EPS ::= 1e-4

load-fcl name/string -> FuzzyModel:
  text := (file.read-contents "fcl/generated/$(name).json").to-string
  return load-model (json.parse text)

check name/string hand/FuzzyModel vectors/List output-count/int -> bool:
  fcl-model := load-fcl name
  ok := true
  vectors.do: | v/List |
    v.size.repeat: | i |
      hand.crisp-input i v[i]
      fcl-model.crisp-input i v[i]
    hand.fuzzify
    fcl-model.fuzzify
    output-count.repeat: | j |
      h := hand.defuzzify j
      f := fcl-model.defuzzify j
      diff := (h - f).abs
      if diff > EPS:
        print "  FAIL  $name input=$v output[$j]: hand=$(%.6f h) fcl=$(%.6f f) diff=$(%.6e diff)"
        ok = false
  if ok: print "  PASS  $name (vectors=$vectors.size, outputs=$output-count)"
  return ok

main:
  any-fail := false

  driver-vectors := [[10.0], [35.0], [70.0], [95.0]]
  if not (check "driver" get-driver driver-vectors 1): any-fail = true

  driver-adv-vectors := [
    [15.0, 5.0, 5.0],
    [50.0, 25.0, 30.0],
    [80.0, 60.0, 75.0],
  ]
  if not (check "driver_advanced" get-driver-advanced driver-adv-vectors 2): any-fail = true

  casco-vectors := [
    [54.82, 20.0,    6.0],
    [12.65,  1.928,  6.0],
    [25.9,   8.55,   6.0],
    [71.69,  8.554,  6.0],
    [71.69, 27.83,   9.036],
    [16.27, 27.83,   9.036],
    [82.53, 27.83,  10.63],
    [ 7.831, 27.83, 10.63],
    [ 7.831,  7.952,10.63],
  ]
  if not (check "casco" get-casco casco-vectors 1): any-fail = true

  fan-vectors := [[2.0, 15.0], [15.0, 40.0], [28.0, 55.0], [40.0, 80.0]]
  if not (check "fan-speed" get-fan-speed fan-vectors 1): any-fail = true

  air-vectors := [[8.0, 15.0], [18.0, 40.0], [28.0, 55.0], [40.0, 80.0]]
  if not (check "air-conditioning" get-air-conditioning air-vectors 1): any-fail = true

  if any-fail:
    print ""
    print "PARITY FAILED — see lines above"
  else:
    print ""
    print "ALL MODELS PASS"
