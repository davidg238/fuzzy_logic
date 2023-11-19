import fuzzy-logic show *
import websocket show Session
import encoding.json
import http

import .models

class FuzzyHTMLview:

  // colors := ["red", "cyan", "lime", "blue"]
  colors := ["aqua", "blue", "teal", "fuchsia", "green", "lime", "maroon", "navy", "olive", "purple", "red", "silver", "yellow", "black"] // , white, gray (or grey)
  session /Session? := null
  model/FuzzyModel? := null
  addr-str/string
  writer/http.ResponseWriter? := null
  tabs := ["Inputs", "Rules", "Outputs"]

  constructor .addr-str/string:

  use session/Session -> none:
    task --background=true::
      i := 1
      while in := session.receive:
        print "received: $in"
        handle-msg in
        model.changed
        model.fuzzify
        model.defuzzify

  write_ str/string -> none:
    writer.write str

  handle-msg msg/string -> none:
    cmd := json.parse msg
    model.crisp-inputs-named cmd.keys.first cmd.values.first.to-float

  update-compositions session/Session -> none:
    session.send "ping"

  write-homepage_ -> none:
    write_
      """
      <!DOCTYPE html>
        <html>
            <head>
                <title>Fuzzy Logic Models</title>
            </head>
            <body>
              <div id="models" class="w3-row-padding">
                <h2>Models</h2>
              </div>
      """
    for i:=0; i<model-names.size; i++:
      write_
        """
        <div class="w3-padding-large">
          <a class="click" href="http://$(addr-str):8080/$model-names[i]/inputs">$model-names[i]</a>
        </div>
        """
    write_ "</body>\n</html>"

  write path/string awriter/http.ResponseWriter -> none:
    writer = awriter
    if path == "/":
      write-homepage_
      return
    parts := split-path path[1..]
    new := get-model parts[0]
    if new == null:
      write_ (page-unknown "Model not found")
      return
    else:
      if (model == null) or (model.name != new.name):
        model = new
        model.fuzzify
        model.defuzzify
    write-page_ parts

  split-path path/string -> List:
    return path.trim.split --at-first=false "/"

  page-unknown reason/string -> string:
    return """
    <!DOCTYPE html>
      <html>
          <head>
          </head>
          <body>
              <p>$reason</p>
          </body>
      </html>
    """

  write-page_ parts/List -> none:
  // TODO: improve
    if parts.size == 1:
      write-model_ 0
    if parts[1] == null:
      write_ (page-unknown "Facet empty")
    else if parts[1] == "inputs":
      write-model_ 0
    else if parts[1] == "rules":
      write-model_ 1
    else if parts[1] == "outputs":
      write-model_ 2
    else:
      write_ (page-unknown "Facet not understood")

  write-model_ tab/int -> none:
    write_
      """
      <!DOCTYPE HTML>
      <html>
        <head>
          <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
      """
    write_ style_
    write_ "</head>"
    write_ (tab==0? "<body onload=\"open_ws_connection()\">" : "<body>")
    write-navigation-div tab
    write-body-div_ tab
    write_ "</body>"
    if tab==0: write-script_
    write_ "</html>"

  write-navigation-div tab/int -> none:
    write_
      """
        <div class="w3-row-padding">
          <a class="click" href="http://$(addr-str):8080">Home</a>
        </div>
        <div class="w3-row-padding">
      """
    write-links_ tab
    write_ "</div>"

  write-links_ tab/int -> none:
  // TODO: improve
    if tab == 0:
      write_ "Inputs <a class=\"click\" href=\"http://$(addr-str):8080/$model.name/rules\">rules</a> <a class=\"click\" href=\"http://$(addr-str):8080/$model.name/outputs\">outputs</a>"
    else if tab == 1:
      write_ "<a class=\"click\" href=\"http://$(addr-str):8080/$model.name/inputs\">inputs</a> Rules <a class=\"click\" href=\"http://$(addr-str):8080/$model.name/outputs\">outputs</a>"
    else:
      write_ "<a class=\"click\" href=\"http://$(addr-str):8080/$model.name/inputs\">inputs</a> <a class=\"click\" href=\"http://$(addr-str):8080/$model.name/rules\">rules</a> Outputs"

  write-body-div_ tab/int -> none:
    write_
      """
        <div class="w3-row-padding">
          <h4>$tabs[tab]</h4>
        </div>
      """
    if tab == 0:      write-inputs_
    else if tab == 1: write-rules_
    else:             write-outputs_
    write_ "</div>"

  // ------------------------------ Inputs ------------------------------

  write-inputs_  -> none:
    write_
      """
          <div id="inputs" class="w3-row-padding">
            <h3>Fuzzy Model: $model.name</h3>
      """
    for i:=0; i<model.inputs.size; i++:
      write-input_ model.inputs[i] model.crisp-inputs[i]
    write_ "</div>"

  write-input_ input/FuzzyInput crisp-in/num-> none:
    write_
      """
            <div id="in1" class="w3-container w3-quarter">
              <p><b>Input:</b> $input.name <b>Sets:</b> $(format-names_ input.set-names)
      """
    write_ "<svg width=\"500\" height=\"400\">"
    write_ graph-grid_
    write_ "<g transform =\"translate (0,400) scale (1, -1)\">"
    write-polylines_ (collect-polylines input.fsets)
    write_ "</g>"
    write_ graph-y-axis_
    write_ "</svg>"
    write_ graph-x-axis_
    write_
      """
              <input type="range" min="1" max="100" value=$crisp-in class="slider" id=$input.name>
            </div>
      """

  // ------------------------------ Rules ------------------------------
  write-rules_ -> none:
    write_
      """
          <div class="w3-row-padding">
          <div class="w3-container w3-third">
      """
    model.rules.do: write_ "$it.stringify </br>"
    write_ "</div>"

  // ------------------------------ Outputs ------------------------------

  write-outputs_ -> none:
    write_ "<div class=\"w3-row-padding\">"
    model.outputs.do: write-composition_ it
    write_ "</div>"

  write-composition_ output/FuzzyOutput -> none:
    print "composition sets: $output.composition.set-names"
    write_ 
      """
            <div class="w3-container w3-quarter">
              <p><b>Sets:</b> $(format-names_ output.composition.set-names)  <b>Output:</b> $output.name <b>Crisp value:</b> $(%.1f output.defuzzify)
              <svg width="500" height="400">
      """
    write_ graph-grid_
    write_ "<g id=\"composition\" transform =\"translate (0,400) scale (1, -1)\">"
    write-polylines_ output.composition.set-polylines
    write-line_ output.composition.centroid-line
    write_
      """
                </g>
                $graph-y-axis_
              </svg>
              $graph-x-axis_
            </div>
      """

  // ------------------------------ Helpers ------------------------------

  format-names_ names/List -> string:
    // <tspan style="color:red">near</tspan>,  <tspan style="color:lime">safe</tspan>,  <tspan style="color:cyan">distant</tspan></p>

    str := ""
    for i:=0; i<names.size; i++:
      str += "<tspan style=\"color:$(colors[i])\">$names[i]</tspan>"
      if i < names.size - 1: str += ", "
    return str

  collect-polylines sets/List -> List:
    
    polys := []
    sets.do:
      polys.add (svg-polyline_ it.polyline)
    return polys

  write-polylines_ polys/List-> none:
    // <polyline points="0.0, 0.0 80.0,400.0 160.0, 0.0" style="stroke:red;fill:red;opacity:0.3" />

    for i:=0; i<polys.size; i++:
      if polys[i].size == 2:
        write_ "<polyline points=\"$(polys[i])\"  style=\"stroke:$(colors[i]);stroke-width:5;fill:$(colors[i]);opacity:0.7\" />\n"
      else:
        write_ "<polyline points=\"$(polys[i])\"  style=\"stroke:$(colors[i]);fill:$(colors[i]);opacity:0.3\" />\n"

  svg-polyline_ points/List -> string:
    txt := ""
    points.do:
        txt += "$(%.1f 4*it.x),$(%.1f 400*it.y) "
    return txt 

  nofill-polyline points-str/string -> string:
    return "<polyline points=\"$(points-str)\" fill=\"none\" style=\"stroke:$(colors[colors.size - 1]);opacity:0.8\" />\n"

  write-line_ line/string -> none:
    write_ "<polyline points=\"$(line)\" fill=\"none\" stroke-dasharray=\"5,5\" style=\"stroke:$(colors[10]);stroke-width:1\" />\n"

  // https://www.tutorialspoint.com/html5/html5_websocket.htm 
  // https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_client_applications

  write-script_ -> none:
    name := ""
    write_
      """
      <script type = "text/javascript">
          var ws;
          
          function send_num(device, num) {
            ws.send('{"' + device + '": ' + num + '}');
          }
          function device_on(adevice) {
            send_num(adevice, 1);
          }
          function device_off(adevice) {
            send_num(adevice, 0);
          }
          function dispatch_msg(msg)  {
            // const obj = JSON.parse(msg)
            //var line = el.appendChild(SVGPolylineElement);
            // line.setAttributes(\"points\", \"10,0.0 20, 50 70,50 80,0.0\");
            /*
            const obj = JSON.parse(msg, function (key, value) {
              var el = document.getElementById(key);
              if (el != null) {
                el.innerHTML = value;
              };
            }); */
          }
      """
    for i:=0; i<model.inputs.size; i++:
      name = model.inputs[i].name
      write_ "document.getElementById(\"$(name)\").addEventListener(\"change\", function() { send_num(\"$(name)\", this.value); });\n"
    write_
      """
          function open_ws_connection() {
            if ("WebSocket" in window) {
                ws = new WebSocket('ws://$(addr-str):8080');
                ws.onopen = function() {
                  document.getElementById("alerts").innerHTML = "-- active --";
                };
                ws.onmessage = function (evt) { 
                  var received_msg = evt.data;
                  dispatch_msg(received_msg);
                };
                ws.onclose = function() {
                  document.getElementById("alerts").innerHTML = "-- closed --";
                };
            } else {
                // The browser doesn't support WebSocket
                alert("WebSocket NOT supported by your Browser!");
            };
          }
      </script>
      """

  style_ -> string:
    return """
      <style>
        .tab {
          overflow: hidden;
          border: 1px solid #ccc;
          background-color: #f1f1f1;
        }
        /* Style the buttons that are used to open the tab content */
        .tab button {
          background-color: inherit;
          float: left;
          border: none;
          outline: none;
          cursor: pointer;
          padding: 14px 16px;
          transition: 0.3s;
        }
        /* Change background color of buttons on hover */
        .tab button:hover {
          background-color: #ddd;
        }

        /* Create an active/current tablink class */
        .tab button.active {
          background-color: #ccc;
        }
        /* Style the tab content */
        .tabcontent {
          display: none;
          padding: 6px 12px;
          border: 1px solid #ccc;
          border-top: none;
        }
        table, th, td {
          padding: 5px;
          border-collapse: collapse;
        }
        .slider {
          width: 400px;
          height: 25px;
          background: #d3d3d3;
          outline: none;
          opacity: 0.7;
          -webkit-transition: .2s;
          transition: opacity .2s;
        }
        .slider:hover {
          opacity: 1;
        }
      </style>
    """
  graph-grid_ -> string:
    return """
                <g transform="translate (0, 400) scale (1,-1)">
                  <line x1="0" y1="0" x2="400" y2="0" stroke="black"/>
                  <line x1="0" y1="80" x2="400" y2="80" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="0" y1="160" x2="400" y2="160" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="0" y1="240" x2="400" y2="240" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="0" y1="320" x2="400" y2="320" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="0" y1="400" x2="400" y2="400" stroke="black"/>
                  
                  <line x1="0" y1="0" x2="0" y2="400" stroke="black"/>
                  <line x1="80" y1="0" x2="80" y2="400" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="160" y1="0" x2="160" y2="400" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="240" y1="0" x2="240" y2="400" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="320" y1="0" x2="320" y2="400" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                  <line x1="400" y1="0" x2="400" y2="400" vector-effect="non-scaling-stroke" stroke="black" stroke-dasharray="20,5" stroke-opacity="0.5" />
                </g>
    """

  graph-y-axis_ -> string:
    return """
                <text x="410" y="400" fill="black" text-anchor="start">0</text>
                <text x="410" y="320" fill="black" text-anchor="start">20</text>
                <text x="410" y="240" fill="black" text-anchor="start">40</text>
                <text x="410" y="160" fill="black" text-anchor="start">60</text>
                <text x="410" y="80" fill="black" text-anchor="start">80</text>
                <text x="410" y="15" fill="black" text-anchor="start">100</text>
    """

  graph-x-axis_ -> string:
    return """
              <svg width="450" height="20">
                <g transform="translate (0, 20) scale (1, 1)">
                  <text x="2" y="0" fill="black" text-anchor="start">0</text>
                  <text x="200" y="0" fill="black" text-anchor="middle">50</text>
                  <text x="398" y="0" fill="black" text-anchor="end">100</text>
                </g>
              </svg>
    """
