import http
import net
import websocket

import .fuzzy_view show *


/**
Example that demonstrates a web-socket server.
The server updates a counter for button presses.
*/

network := net.open
addr_str := network.address.stringify
server := http.Server

main:

  fuzzy_view := FuzzyHTMLview addr_str

  print "Open a browser on: http://$network.address:8080"
  sessions := {:}
  server.listen network 8080:: | request/http.Request writer/http.ResponseWriter |
    if websocket.is_websocket_upgrade request:
      session := websocket.Session.upgrade request writer
      peer_address := session.peer_address
      sessions[peer_address] = session
      // print "session created for $peer_address"
      fuzzy_view.use session
      sessions.remove peer_address
      // print "....... removed for $peer_address"
    else:
      if request.path == "/599":
        writer.write_headers 599 --message="Dazed and confused"
      else:
        fuzzy_view.write request.path writer