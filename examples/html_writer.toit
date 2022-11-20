import fuzzy_logic show *

/*

        slider.onchange = function() {
          // output.innerHTML = this.value;
          ws.send("22 was here");
        }

*/


class HtmlWriter:


  as_html model/FuzzyModel port/string -> string:

    return """
    <!DOCTYPE html PUBLIC \"-//IETF//DTD HTML 2.0//EN\">\n
    <HTML>\n
    <HEAD>
      <TITLE>Fuzzy Model</TITLE>
      <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
      <style>
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
      </HEAD>\n
    <BODY>
      <div id="inputs" class="w3-row-padding">
        <h1>Fuzzy Model</h1>
        <h2>Inputs</h2>
        <div id="in1" class="w3-container w3-quarter">
          <svg width=\"400\" height=\"400\">\n
            <g transform="translate (0, 375) scale (1,-1)">
              <rect x=\"0\" y=\"0\" width=\"15\" height=\"100\"  style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"40\" y=\"0\" width=\"15\" height=\"90\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"80\" y=\"0\" width=\"15\" height=\"170\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"120\" y=\"0\" width=\"15\" height=\"180\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"160\" y=\"0\" width=\"15\" height=\"120\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"200\" y=\"0\" width=\"15\" height=\"190\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"240\" y=\"0\" width=\"15\" height=\"195\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"280\" y=\"0\" width=\"15\" height=\"190\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"320\" y=\"0\" width=\"15\" height=\"110\" style=\"fill:rgb(0,0,255)\" />\n
              <rect x=\"360\" y=\"0\" width=\"15\" height=\"175\" style=\"fill:rgb(0,0,255)\" />\n
            </g>
            <g transform="translate (0, 395)">
              <text x=\"2\" y=\"0\" fill=\"black\" text-anchor=\"start\">0</text>\n
              <text x=\"220\" y=\"0\" fill=\"black\" text-anchor=\"middle\">50</text>\n
              <text id="fred" x=\"398\" y=\"0\" fill=\"black\" text-anchor=\"end\">100</text>\n
            </g>
          </svg>\n
          <input type="range" min="1" max="100" value="50" class="slider" id="input01">
          <p>Input: distance</p>
        </div>
      </div>
      <div id="rules" class="w3-row-padding">
        <h2>Rules</h2>
        FuzzyRule 0 (Antecedent.set small) (Consequent.output slow)</p>
        FuzzyRule 1 (Antecedent.set safe) (Consequent.output average)</p>
        FuzzyRule 2 (Antecedent.set big) (Consequent.output fast)</p>
      </div>
      <div id="output" class="w3-row-padding">
        <h2>Output</h2>
      </div>
      <script type = "text/javascript">
        var ws = new WebSocket(\"ws://192.168.0.240:$port\");
        var slider = document.getElementById("input01");
        var output = document.getElementById("fred");

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
        
      </script>
    </BODY>\n
    </HTML>\n
    """