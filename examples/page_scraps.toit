INSIDE ::= "inside"
OUTSIDE ::= "outside"
POWER ::= "power"

HOUR ::= "hour"

IN_TEMP ::= "inside_temperature"
IN_HUM ::= "inside_humidity"
IN_LUM ::= "inside_luminance"
IN_AIRQ ::= "inside_air_quality"

OUT_TEMP ::= "outside_temperature"
OUT_HUM ::= "outside_humidity"
OUT_WINDSPEED ::= "outside_windspeed"
OUT_WINDDIRECTION ::= "outside_winddirection"
OUT_RAINRATE ::= "outside_rainrate"

FAN_SPEED_SP ::= "fan_speed_sp"
FAN_SPEED ::= "fan_speed"
PUMP_RUN ::= "pump_run"
PUMP_RNG ::= "pump_rng"

PANEL_V ::= "panel_voltage"
BATTERY_V ::= "battery_voltage"
LOAD_I ::= "load_current"
MAINS ::= "mains_power"

DOOR ::= "door"

style := """
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
    </style>
"""

script := """
  <script type = "text/javascript">
    var ws;
    
    document.getElementById("default_tab").click();
    /*  ... was for pump_rng
    var canvas = document.getElementById("$PUMP_RNG");
    var context = canvas.getContext("2d");
    context.arc(10, 10, 10, 0, Math.PI * 2, false);
    context.fillStyle = "red";
    context.fill()
    */

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
      
      const obj = JSON.parse(msg, function (key, value) {
        var el = document.getElementById(key)
        if (el != null) {
          el.innerHTML = value;
        };
      });
      /*  ... was for pump_rng
      const obj = JSON.parse(msg, function (key, value) {
        var el = document.getElementById(key)
        if (el != null) {
          document.getElementById("alerts").innerHTML = key;
          if (key == $PUMP_RNG) {
            document.getElementById("alerts").innerHTML = "found";
            var target = el.getContext("2d");
            if (value == 0) {
              target.fillSytle = "red";
              console.log("red");
            } else {
              target.fillSytle = "green";
              console.log("green");
            };
          } else {
            el.innerHTML = value;
          };
        };
      });
      */
    }
    function open_ws_connection() {
      if ("WebSocket" in window) {
          ws = new WebSocket('ws://$(addr_str):8080');
          ws.onopen = function() {
            document.getElementById("alerts").innerHTML = "-- active --";
          };
          ws.onmessage = function (evt) { 
            var received_msg = evt.data;
            dispatch_msg(received_msg)
          };
          ws.onclose = function() {
            document.getElementById("alerts").innerHTML = "-- closed --";
          };
      } else {
          // The browser doesn't support WebSocket
          alert("WebSocket NOT supported by your Browser!");
      }
    }
    function openTab(evt, tabName) {
      // Declare all variables
      var i, tabcontent, tablinks;

      // Get all elements with class="tabcontent" and hide them
      tabcontent = document.getElementsByClassName("tabcontent");
      for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
      }

      // Get all elements with class="tablinks" and remove the class "active"
      tablinks = document.getElementsByClassName("tablinks");
      for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
      }

      // Show the current tab, and add an "active" class to the button that opened the tab
      document.getElementById(tabName).style.display = "block";
      evt.currentTarget.className += " active";
    }
  </script>
"""

spa := """
<!DOCTYPE HTML>
<html>
  <head>
    $style
  </head>
  <body onload="open_ws_connection()">
  <h1>Greenhouse</h1>
  <div class="tab">
  <button class="tablinks" onclick="openTab(event, '$INSIDE')" id="default_tab">Inside</button>
  <button class="tablinks" onclick="openTab(event, '$OUTSIDE')">Outside</button>
  <button class="tablinks" onclick="openTab(event, '$POWER')">Power</button>
  </div>

  <!-- Tab content -->
  <div id="$INSIDE" class="tabcontent">
    $tabcontent_inside
  </div>
  <div id="$OUTSIDE" class="tabcontent">
    $tabcontent_outside
  </div>
  <div id="$POWER" class="tabcontent">
    $tabcontent_power
  </div>
  <br><br>
  Hour: <span id=$HOUR> -- </span><br>
  <div id="alerts"> -- -- </div>
  </body>
  $script
</html>
"""

tabcontent_inside := """
    <table>
    <tr>
      <td>Fan Speed SP</td>
      <td></td>
      <td><input onchange='send_num("$FAN_SPEED_SP", this.value)' type="range" min="1" max="100" value="20" class="slider" id=$FAN_SPEED_SP></td>
    </tr>
    <tr>
      <td>Evap Cooler Pump</td>
      <td><button onclick='device_off("$PUMP_RUN")'>Stop</button>&nbsp;<button onclick='device_on("$PUMP_RUN")'>Run</button></td>
      <td><label id=$PUMP_RNG> -- <label></td>
    </tr>
    </table>
    <br>
    <br>
     <table>
    <tr><td>Temperature</td><td><label id=$IN_TEMP> -- <label></td><td>F</td></tr>
    <tr><td>Humidity</td><td><label id=$IN_HUM> -- <label></td><td>%</td></tr>
    <tr><td>Luminance</td><td><label id=$IN_LUM> -- <label></td><td></td></tr>
    <tr><td>Air Quality</td><td><label id=$IN_AIRQ> -- <label></td><td>ppm</td></tr>
    </table>
"""
tabcontent_outside := """
    <table>
    <tr><td>Door          </td><td><label id=$DOOR> -- <label></td><td></td></tr>
    <tr><td>Temperature   </td><td><label id=$OUT_TEMP> -- <label></td><td>F</td></tr>
    <tr><td>Humidity      </td><td><label id=$OUT_HUM> -- <label></td><td>%</td></tr>
    <tr><td>Wind Speed    </td><td><label id=$OUT_WINDSPEED> -- <label></td><td>mph</td></tr>
    <tr><td>Wind Direction</td><td><label id=$OUT_WINDDIRECTION> -- <label></td><td></td></tr>
    <tr><td>Rain rate     </td><td><label id=$OUT_RAINRATE> -- <label></td><td>in/hr</td></tr>
    </table>
"""

tabcontent_power := """
    <table>
    <tr><td>Solar Panel   </td><td><label id=$PANEL_V> -- <label></td><td>V</td></tr>
    <tr><td>Battery </td><td><label id=$BATTERY_V> -- <label></td><td>V</td></tr>
    <tr><td>Load    </td><td><label id=$LOAD_I> -- <label></td><td>mA</td></tr>
    <tr><td>Mains Available </td><td><label id=$MAINS> -- <label></td><td></td></tr>
    </table>
"""
