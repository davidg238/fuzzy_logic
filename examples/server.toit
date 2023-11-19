import http
import net
import websocket

import .fuzzy-view show *


/**
Example that demonstrates a web-socket server.
The server updates a counter for button presses.
*/

network := net.open
addr-str := network.address.stringify
server := http.Server

main:

  fuzzy-view := FuzzyHTMLview addr-str

  print "Open a browser on: http://$network.address:8080"
  sessions := {:}
  server.listen network 8080:: | request/http.Request writer/http.ResponseWriter |
    if websocket.is-websocket-upgrade request:
      session := websocket.Session.upgrade request writer
      peer-address := session.peer-address
      sessions[peer-address] = session
      // print "session created for $peer_address"
      fuzzy-view.use session
      sessions.remove peer-address
      // print "....... removed for $peer_address"
    else:
      if request.path == "/599":
        writer.write-headers 599 --message="Dazed and confused"
      else:
        fuzzy-view.write request.path writer