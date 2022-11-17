// Copyright (C) 2021 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import http
import encoding.json
import net
import fuzzy_logic show *

ITEMS := ["FOO", "BAR", "BAZ"]

comp := Composition
points_str := ""
set_str := ""
circles_str := ""
comp_union_points := ""

//small := LTrapezoidalSet 0.0 10.0 60.0 "small"
tri := FuzzySet 0.0 20.0 20.0 40.0 "tri"
tri1 := (FuzzySet 0.0 10.0 10.0 20.0 "tri1")
tri2 := (FuzzySet 10.0 20.0 20.0 30.0 "tri2")

trap1  := FuzzySet 10.0 25.0 60.0 75.0 "trap1"
trap2  := FuzzySet 35.0 50.0 70.0 85.0 "trap2"

sets := [tri1, tri2]

main:

  tri.pertinence 1.0
  tri1.pertinence 1.0
  tri2.pertinence 1.0

  trap1.pertinence  0.75
  trap2.pertinence  0.5

  sets_as_string
/*
  sets.do:
    comp.union it.truncated
  
  points_as_string
  points_as_svg

  points_str = comp.as_svg_polyline
*/
  task:: webserver_task
//  task:: websocketserver_task


webserver_task:
  network := net.open
  server := http.Server
  server.listen network 8080:: | request/http.Request writer/http.ResponseWriter |
    if request.path == "/num":
//      writer.headers.set "Content-Type" "text/event-stream"
//      writer.headers.set "Cache-Control" "no-cache"
      writer.write sampleHTML

sets_as_string -> none:
  sets.do:
    set_str += "<h3>$it</h3>\n"


points_as_string:
  comp_union_points = comp.test_points.stringify

points_as_svg -> none:
  circles_str = ""
  comp.test_points.do:
    circles_str += "<circle cx=\"$(it.x*5)\" cy=\"$(it.y*400)\" r=\"2\" stroke=\"black\" stroke-width=\"1\" fill=\"red\" />\n"
/*
websocketserver_task:

  sessions := {:}

  network := net.open
  server := http.Server
  server.listen network 8081:: | request/http.Request response/http.ResponseWriter |
    session := websocket.Session.upgrade request response

    task::
      peer_address := session.peer_address
      sessions[peer_address] = session
      while msg := session.receive:
        sessions.do --values: it.send msg
      sessions.remove peer_address      

*/

page_h := """
<!DOCTYPE html>
<html>
<body>
"$set_str"
<svg height="500" width="600">
<g transform="translate (100, 450) scale (1,-1)">


</g>
</svg>
</body>
</html>
"""
// <polygon id='b' points="$points_str" style="stroke:black;stroke-width:1;opacity:0.1"/>\n

// <h3>"$(comp_union_points)"</h3>
// "$circles_str"
page_sse := """
  so here is some text
  <div id="serverData">Here is where the server sent data will appear</div>
  last text, before script
  <p>My first paragraph.</p>
  <canvas id='drawing' width="600" height="600" style="border:1px solid #c3c3c3;">
  Your browser does not support the canvas element.
  </canvas>
  <script>
  var canvas = document.getElementById("drawing");
  var ctx = canvas.getContext('2d');
  ctx.fillStyle = '#f00';
  ctx.beginPath();
  ctx.moveTo(0, 0);
  ctx.lineTo(100,50);
  ctx.lineTo(50, 100);
  ctx.lineTo(0, 90);
  ctx.closePath();
  ctx.fill();
  var poly = document.getElementById('a');
  poly.style.fill = 'yellow';
  </script>

  <script type="text/javascript">
    if(typeof(EventSource)!=="undefined") {
	  //create an object, passing it the name and location of the server side script
	  var eSource = new EventSource("send_sse.toit");
	  //detect message receipt
	  eSource.onmessage = function(event) {
		  //write the received data to the page
		  document.getElementById("serverData").innerHTML = event.data;
	  };
  }
  else {
	  document.getElementById("serverData").innerHTML="Whoops! Your browser doesn't receive server-sent events.";
  }
  </script>
  """

page_ws := """
<!DOCTYPE HTML>
<html>
   <head>
      <script type = "text/javascript">
         function WebSocketTest() {
            if ("WebSocket" in window) {
               alert("WebSocket is supported by your Browser!");
               // Let us open a web socket
               var ws = new WebSocket("ws://192.168.0.220:8081");
               ws.onopen = function() {
                  // Web Socket is connected, send data using send()
                  ws.send("Message to send");
                  alert("Message is sent...");
               };
               ws.onmessage = function (evt) { 
                  var received_msg = evt.data;
                  alert("Message is received...");
               };
               ws.onclose = function() { 
                  
                  // websocket is closed.
                  alert("Connection is closed..."); 
               };
            } else {
               // The browser doesn't support WebSocket
               alert("WebSocket NOT supported by your Browser!");
            }
         }
      </script>
   </head>
   <body>
      <div id = "sse">
         <a href = "javascript:WebSocketTest()">Run WebSocket</a>
      </div>
   </body>
</html>
"""
sampleHTML := """

  <!DOCTYPE html PUBLIC \"-//IETF//DTD HTML 2.0//EN\">\n
  <HTML>\n
  <HEAD><TITLE>A Small Hello</TITLE></HEAD>\n
  <BODY>A minimal \"hello world\" HTML <a href=\"http://www.caniretireyet.com\">document</a>.</P>\n
  <svg width=\"80\" height=\"80\">\n
    <circle cx=\"50\" cy=\"50\" r=\"28\" stroke=\"green\" stroke-width=\"4\" fill=\"yellow\" />\n
  </svg></P>\n
  with a couple of embedded SVGs</P>\n
  <svg width=\"400\" height=\"300\">\n
  <rect x=\"0\" y=\"150\" width=\"15\" height=\"100\"  style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"20\" y=\"160\" width=\"15\" height=\"90\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"40\" y=\"80\" width=\"15\" height=\"170\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"60\" y=\"70\" width=\"15\" height=\"180\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"80\" y=\"130\" width=\"15\" height=\"120\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"100\" y=\"30\" width=\"15\" height=\"220\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"120\" y=\"10\" width=\"15\" height=\"240\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"140\" y=\"60\" width=\"15\" height=\"190\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"160\" y=\"40\" width=\"15\" height=\"210\" style=\"fill:rgb(0,0,255)\" />\n
  <rect x=\"180\" y=\"75\" width=\"15\" height=\"175\" style=\"fill:rgb(0,0,255)\" />\n
  <text x=\"0\" y=\"270\" fill=\"black\">0</text>\n
  <text x=\"80\" y=\"270\" fill=\"black\">5</text>\n
  <text x=\"180\" y=\"270\" fill=\"black\">10</text>\n
  </svg>\n
  </BODY>\n
  </HTML>\n
  """