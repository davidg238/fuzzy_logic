import fuzzy_logic show *
import websocket show Session
import encoding.json
import http

import .models

class FuzzyHTMLview:

  // colors := ["red", "cyan", "lime", "blue"]
  colors := ["aqua", "blue", "teal", "fuchsia", "green", "lime", "maroon", "navy", "olive", "purple", "red", "silver", "yellow", "black"] // , white, gray (or grey)
  session /Session? := null
  model/FuzzyModel? := null
  addr_str/string
  writer/http.ResponseWriter? := null
  tabs := ["Inputs", "Rules", "Outputs"]

  constructor .addr_str/string:

  use session/Session -> none:
    task --background=true::
      i := 1
      while in := session.receive:
        print "received: $in"
        handle_msg in
        model.changed
        model.fuzzify
        model.defuzzify
//        print_objects

  html_ str/string -> none:
    writer.write str

  handle_msg msg/string -> none:
    cmd := json.parse msg
    model.crisp_inputs_named cmd.keys.first cmd.values.first.to_float

  update_compositions session/Session -> none:
    session.send "ping"

  write_homepage_ -> none:
    html_
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
    for i:=0; i<model_names.size; i++:
      html_
        """
        <div class="w3-padding-large">
          <a class="click" href="http://$(addr_str):8080/$model_names[i]/inputs">$model_names[i]</a>
        </div>
        """
    html_ "</body>\n</html>"

  write path/string awriter/http.ResponseWriter -> none:
    writer = awriter
    if path == "/":
      write_homepage_
      return
    parts := split_path path[1..]
    new := get_model parts[0]
    if new == null:
      html_ (page_unknown "Model not found")
      return
    else:
      if (model == null) or (model.name != new.name):
        model = new
        model.fuzzify
        model.defuzzify
    write_page_ parts

  split_path path/string -> List:
    return path.trim.split --at_first=false "/"

  page_unknown reason/string -> string:
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

  write_page_ parts/List -> none:
  // TODO: improve
    if parts.size == 1:
      write_model_ 0
    if parts[1] == null:
      html_ (page_unknown "Facet empty")
    else if parts[1] == "inputs":
      write_model_ 0
    else if parts[1] == "rules":
      write_model_ 1
    else if parts[1] == "outputs":
      write_model_ 2
    else:
      html_ (page_unknown "Facet not understood")

  write_model_ tab/int -> none:
    html_
      """
      <!DOCTYPE HTML>
      <html>
        <head>
          <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
      """
    html_ style_
    html_ "</head>"
    html_ (tab==0? "<body onload=\"open_ws_connection()\">" : "<body>")
    write_navigation_div tab
    write_body_div_ tab
    html_ "</body>"
    if tab==0: write_script_
    html_ "</html>"

  write_navigation_div tab/int -> none:
    html_
      """
        <div class="w3-row-padding">
          <a class="click" href="http://$(addr_str):8080">Home</a>
        </div>
        <div class="w3-row-padding">
      """
    write_links_ tab
    html_ "</div>"

  write_links_ tab/int -> none:
  // TODO: improve
    if tab == 0:
      html_ "Inputs <a class=\"click\" href=\"http://$(addr_str):8080/$model.name/rules\">rules</a> <a class=\"click\" href=\"http://$(addr_str):8080/$model.name/outputs\">outputs</a>"
    else if tab == 1:
      html_ "<a class=\"click\" href=\"http://$(addr_str):8080/$model.name/inputs\">inputs</a> Rules <a class=\"click\" href=\"http://$(addr_str):8080/$model.name/outputs\">outputs</a>"
    else:
      html_ "<a class=\"click\" href=\"http://$(addr_str):8080/$model.name/inputs\">inputs</a> <a class=\"click\" href=\"http://$(addr_str):8080/$model.name/rules\">rules</a> Outputs"

  write_body_div_ tab/int -> none:
    html_
      """
        <div class="w3-row-padding">
          <h4>$tabs[tab]</h4>
        </div>
      """
    if tab == 0:      write_inputs_
    else if tab == 1: write_rules_
    else:             write_outputs_
    html_ "</div>"

  // ------------------------------ Inputs ------------------------------

  write_inputs_  -> none:
    html_
      """
          <div id="inputs" class="w3-row-padding">
            <h3>Fuzzy Model: $model.name</h3>
      """
    for i:=0; i<model.inputs.size; i++:
      write_input_ model.inputs[i] model.crisp_inputs[i]
    html_ "</div>"

  write_input_ input/FuzzyInput crisp_in/num-> none:
    html_
      """
            <div id="in1" class="w3-container w3-quarter">
              <p><b>Input:</b> $input.name <b>Sets:</b> $(format_names_ input.set_names)
      """
    html_ "<svg width=\"500\" height=\"400\">"
    html_ graph_grid_
    html_ "<g transform =\"translate (0,400) scale (1, -1)\">"
    write_polylines_ (collect_polylines input.fsets)
    html_ "</g>"
    html_ graph_y_axis_
    html_ "</svg>"
    html_ graph_x_axis_
    html_
      """
              <input type="range" min="1" max="100" value=$crisp_in class="slider" id=$input.name>
            </div>
      """

  // ------------------------------ Rules ------------------------------
  write_rules_ -> none:
    html_
      """
          <div class="w3-row-padding">
          <div class="w3-container w3-third">
      """
    model.rules.do: html_ "$it.stringify </br>"
    html_ "</div>"

  // ------------------------------ Outputs ------------------------------

  write_outputs_ -> none:
    html_ "<div class=\"w3-row-padding\">"
    model.outputs.do: write_composition_ it
    html_ "</div>"

  write_composition_ output/FuzzyOutput -> none:
    print "composition sets: $output.composition.set_names"
    html_ 
      """
            <div class="w3-container w3-quarter">
              <p><b>Sets:</b> $(format_names_ output.composition.set_names)  <b>Output:</b> $output.name <b>Crisp value:</b> $(%.1f output.defuzzify)
              <svg width="500" height="400">
      """
    html_ graph_grid_
    html_ "<g id=\"composition\" transform =\"translate (0,400) scale (1, -1)\">"
    write_polylines_ output.composition.set_polylines
    write_line_ output.composition.centroid_line
    html_
      """
                </g>
                $graph_y_axis_
              </svg>
              $graph_x_axis_
            </div>
      """

  // ------------------------------ Helpers ------------------------------

  format_names_ names/List -> string:
    // <tspan style="color:red">near</tspan>,  <tspan style="color:lime">safe</tspan>,  <tspan style="color:cyan">distant</tspan></p>

    str := ""
    for i:=0; i<names.size; i++:
      str += "<tspan style=\"color:$(colors[i])\">$names[i]</tspan>"
      if i < names.size-1: str += ", "
    return str

  collect_polylines sets/List -> List:
    
    polys := []
    sets.do:
      polys.add (svg_polyline_ it.polyline)
    return polys

  write_polylines_ polys/List-> none:
    // <polyline points="0.0, 0.0 80.0,400.0 160.0, 0.0" style="stroke:red;fill:red;opacity:0.3" />

    for i:=0; i<polys.size; i++:
      if polys[i].size == 2:
        html_ "<polyline points=\"$(polys[i])\"  style=\"stroke:$(colors[i]);stroke-width:5;fill:$(colors[i]);opacity:0.7\" />\n"
      else:
        html_ "<polyline points=\"$(polys[i])\"  style=\"stroke:$(colors[i]);fill:$(colors[i]);opacity:0.3\" />\n"

  svg_polyline_ points/List -> string:
    txt := ""
    points.do:
        txt += "$(%.1f 4*it.x),$(%.1f 400*it.y) "
    return txt 

  nofill_polyline points_str/string -> string:
    return "<polyline points=\"$(points_str)\" fill=\"none\" style=\"stroke:$(colors[colors.size-1]);opacity:0.8\" />\n"

  write_line_ line/string -> none:
    html_ "<polyline points=\"$(line)\" fill=\"none\" stroke-dasharray=\"5,5\" style=\"stroke:$(colors[10]);stroke-width:1\" />\n"

  // https://www.tutorialspoint.com/html5/html5_websocket.htm 
  // https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_client_applications

  write_script_ -> none:
    name := ""
    html_
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
      html_ "document.getElementById(\"$(name)\").addEventListener(\"change\", function() { send_num(\"$(name)\", this.value); });\n"
    html_
      """
          function open_ws_connection() {
            if ("WebSocket" in window) {
                ws = new WebSocket('ws://$(addr_str):8080');
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
  graph_grid_ -> string:
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

  graph_y_axis_ -> string:
    return """
                <text x="410" y="400" fill="black" text-anchor="start">0</text>
                <text x="410" y="320" fill="black" text-anchor="start">20</text>
                <text x="410" y="240" fill="black" text-anchor="start">40</text>
                <text x="410" y="160" fill="black" text-anchor="start">60</text>
                <text x="410" y="80" fill="black" text-anchor="start">80</text>
                <text x="410" y="15" fill="black" text-anchor="start">100</text>
    """

  graph_x_axis_ -> string:
    return """
              <svg width="450" height="20">
                <g transform="translate (0, 20) scale (1, 1)">
                  <text x="2" y="0" fill="black" text-anchor="start">0</text>
                  <text x="200" y="0" fill="black" text-anchor="middle">50</text>
                  <text x="398" y="0" fill="black" text-anchor="end">100</text>
                </g>
              </svg>
    """
