import encoding.json

main:

  str := "{\"speed\": 21}"
  cmd := json.parse str
  input := cmd.keys.first
  print input