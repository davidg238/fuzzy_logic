import encoding.json

main:

/*
  str := "{\"speed\": 21}"
  cmd := json.parse str
  input := cmd.keys.first
  print input
  */

  str := "/casco/inputs"
  str1 := str[1..]
  str2 := str1.trim
  parts := str2.split --at_first=false "/"
  print "model $parts[0]"
  print "page $parts[1]"
  
