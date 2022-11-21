import http
import net
import websocket

import .models show *
import .html_writer show *


/**
Example that demonstrates a web-socket server.
The server updates a counter for button presses.
*/

network := net.open
addr_str := network.address.stringify
server := http.Server

model := get_model "driver_advanced"
html_writer := FuzzyWriter model addr_str

main:

  model.set_input 0 35.0
//  model.fuzzify

  print "Open a browser on: $network.address:8080"
  sessions := {:}
  server.listen network 8080:: | request/http.Request response/http.ResponseWriter |
    if websocket.is_websocket_upgrade request:
      session := websocket.Session.upgrade request response
      peer_address := session.peer_address
      sessions[peer_address] = session
      print "session created for $peer_address"
      handle session
      sessions.remove peer_address
      print "....... removed for $peer_address"

    else:
      print request.path
      if request.path == "/":
        response.write spa
      else if request.path == "/599":
        response.write_headers 599 --message="Dazed and confused"
      else:
        response.write_headers 404
      print "request path finished"

handle session/websocket.Session -> none:
  task --background=true::
    i := 1
    while in := session.receive:
      print "received: $in"
      model.handle_msg in
      // session.send "{\"counter\": $i}"
      // i += 1

spa -> string:

  //print model

  str := html_writer.page
  // print str
  return str