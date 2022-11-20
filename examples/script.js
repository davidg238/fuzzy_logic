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
      
      const obj = JSON.parse(msg, function (key, value) {
        var el = document.getElementById(key);
        if (el != null) {
          el.innerHTML = value;
        };
      });
    }

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