https://www.tutorialspoint.com/html5/html5_websocket.htm  --


[jQuery SVG](http://keith-wood.name/svg.html)  presumably as a plugin, you also need jQuery  2014 !

[Two.js](https://two.js.org/) ... appears to be owner drawn SVG ... min is 43kB  



[SVG-Edit](https://github.com/SVG-Edit/svgedit) ... looks like an editor, "looks" big

[svgweb](https://code.google.com/archive/p/svgweb/) 2011 !

// -------------------------------------------------------

[pablo](https://github.com/premasagar/pablo) ... 9yr old, looks nice?

[SVG.js](https://svgjs.dev/docs/3.0/) and [source](https://github.com/svgdotjs) ... different files to draw, manipulate, events  




<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="bOWdrp" data-user="fuzzyma" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/fuzzyma/pen/bOWdrp">
  Animated Weather Graph</a> by Ulrich-Matthias Schäfer (<a href="https://codepen.io/fuzzyma">@fuzzyma</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>


<input type="range" min="0" max="1" step="0.01" value="0">

html, body {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  background: #111;
}

input {
  width: 70%;
  display: block;
  margin: auto;
  padding: 25px;
}



/************************************
  This codepen is part of the svg.js
  advent calendar. You can find all
  the pens at twitter: @svg_js
*************************************/

// Please scroll below the data ;)
const dataPoints = [18.6,17.9,13,11.1,4,6.2,-5.4,-3,-2.8,12.4,10,11.6,16.8,10,15.9,16.8,17.9,17.4,18.6,14.8,14.8,17.9,10,6.2,8.9,7.6,0.9,3.2,-0.8,3.2,15.4,7.5,1.6,11.3,8.9,15.9,16.6,7,13.8,16.8,17.9,13.2,10,8.1,10.2,8.3,8.9,16.6,14.8,8.9,16.8,10,11.8,17.2,19.7,18.6,5.6,13,17.5,17.9,9.1,17.3,17.4,14.5,7,9.4,6.2,1.5,5.3,10,8.1,11.6,11.9,13,16.1,18.7,19,18.6,16.6,20.1,15.9,18.7,19.7,13.8,13.8,17.4,16.2,22.8,9.9,15.1,13,11.6,15.9,16.9,17,17.6,17.9,15.9,16.6,20.4,13.3,12.5,14.2,13.9,16.4,15.5,15.3,22.8,23.1,22.4,20.4,12.7,15,18.2,19.2,12.8,15,17.2,17.8,16.1,21.1,17.8,22.4,21.7,23.9,24.6,24.2,22.2,17.8,22.4,18.2,21.9,23.1,23.9,20,18.9,22.2,21.1,22.8,23.5,22.8,22.2,22.2,22.2,19.2,21.3,23.3,22.4,22.8,25.1,24.6,22.2,22.2,20,22.2,24.6,22.8,22.8,25.3,25.3,26.1,24.6,20,22.6,24.9,22.2,25.3,26.4,24.6,26.6,25.8,25.7,23.1,25.8,25.1,25.7,25.1,25.4,23.8,23.1,25.4,23.1,24.6,25.1,26.6,26.7,24.2,24.6,23.9,23.1,26.6,26,26.3,25.7,25.3,22.8,23.1,21.8,23.9,22.4,24.2,22.8,25.3,26.6,24.2,24.2,27.2,27.7,23.1,23.9,24.3,26.7,27,26.9,26.6,26.9,26.4,26,22.8,26.4,23.1,25.7,26.1,22.8,20.4,25.3,24.9,23.1,23.6,22.9,23.5,21.5,17.7,20.7,16,18.6,20.4,15,22.2,23.1,22.2,21.1,22.8,22.2,23.6,22,20.4,21.7,24.3,21.1,24.5,22.8,19.3,20.8,22.1,22.6,23.2,23.9,22.8,23.9,23.9,22.2,21.1,25.2,25,25.3,18.2,21.9,15.9,24.2,22.2,15,12.8,9.4,16.6,19,17.8,21.1,17.2,17.8,21.1,12.8,14.1,15.5,17,14.4,19.7,2.3,16,1.1,12.5,17.8,8.9,12.2,7.2,17.2,18.9,6.7,5.1,2.2,7.2,2.2,6,2.9,18.2,17.2,17.2,20.4,7.8,20,21.1,1.5,6.1,2.5,7,8.9]


const width = window.innerWidth
const height = window.innerHeight - 100

// Define our graph width and height
// and the space between data points
const graphWidth = 700
const graphHeight = 600
const pointMargin = 20

const canvas = SVG()
  .addTo('body')
  .size(width, height)
  .viewbox(-25, -25, graphWidth+50, graphHeight+50)

// Create a nice hsl gradient and rotate it by 90 degrees
const temperaturGradient = canvas.gradient('linear', (add) => {
  add.stop(0, 'hsl(0,100%,50%)')
  add.stop(0.1, 'hsl(25,100%,50%)')
  add.stop(0.2, 'hsl(50,100%,50%)')
  add.stop(0.3, 'hsl(75,100%,50%)')
  add.stop(0.4, 'hsl(100,100%,50%)')
  add.stop(0.5, 'hsl(125,100%,50%)')
  add.stop(0.6, 'hsl(150,100%,50%)')
  add.stop(0.7, 'hsl(175,100%,50%)')
  add.stop(0.8, 'hsl(200,100%,50%)')
  add.stop(0.9, 'hsl(225,100%,50%)')
  add.stop(1, 'hsl(250,100%,50%)')
}).transform({rotate: 90})

// Create a mask and mask a big rectangle with our gradient
const mask = canvas.mask()
canvas.rect(graphWidth+50, graphHeight+50)
  .move(-25, -25)
  .fill(temperaturGradient)
  .maskWith(mask)

// Calculates data, min and max temperatur and scaling
const getDataSlice = (start, end) => {
  const data = dataPoints.slice(start, end)
  const min = Math.min(...data)
  const max = Math.max(...data)
  const scale = graphHeight / (max - min)
  return [min, max, scale, data]
}

// Converts data to coordinates
const getDataPoints = (
  start = 0,
  end = Math.floor(graphWidth/pointMargin)
) => {
  // Get params
  const [min, max, scale, data] = getDataSlice(start, end)

  // Map data to coordinates
  return data.map((temperatur, i, arr) => {
    return [
      pointMargin * i,
      graphHeight - scale * (temperatur - min)
    ]
  })
}

// Get Points for initial view
const initialData = getDataPoints()

// Create initial polygon
const poly = mask.polyline(initialData)
  .fill('none')
  .stroke({
    color: 'white',
    opacity: 0.5, width: 3
  })
  .animate(new SVG.Spring(700))

// Create initial circles
const circles = new SVG.List(initialData.map(([cx, cy]) => {
  return mask.circle(pointMargin/2)
    .center(cx, cy)
    .fill({color: 'white', opacity: 0.5})
    .stroke({color: 'white', width: 3})
    .animate(new SVG.Spring(700))
}))

// Update the polyline and the circles
const updateGraph = (start, end) => {
  const data = getDataPoints(start, end)
  poly.plot(data)
  data.forEach(([cx, cy], i) => {
    circles[i].center(cx, cy)
  })
}

// Mathematically correct mod func
const mod = (x, m) => x % m + (x < 0 ? m : 0)

// Update the grid and the labels
const updateGrid = (start, end) => {
  // Remove text and lines before drawing new ones
  canvas.find('line, text').remove()

  const [min, max, scale] = getDataSlice(start, end)

  // Create y-Bar
  const yBar = canvas.line(0, -50, 0, graphHeight + 50)
    .stroke({color: 'white', width: 3, opacity: 0.5})

  // Figure out lowest line
  let curr = min - mod(min, 2) + 2
  for (; curr <= max; curr += 2) {
    // Draw value lines
    canvas.line(
      0, graphHeight - (curr - min) * scale,
      graphWidth, graphHeight - (curr - min) * scale
    ).stroke({
      color: 'white',
      width: 2,
      opacity: curr ? 0.3 : 1
    })

    // Add text to every line
    canvas.text(curr.toString())
      .center(-15, graphHeight - (curr - min) * scale)
      .fill('white')
  }
}

// Update the graph when the slider is moved
const handleSlider = () => {
  clearTimeout(timeout)

  // Get the value of the slider
  const value = SVG('input').node.value

  const start = 0
  const end = (dataPoints.length * pointMargin - graphWidth) / pointMargin

  // Calculate index of first and last data point
  const startIndex = Math.ceil((end - start) * value)
  const endIndex = Math.floor(startIndex + graphWidth / pointMargin)

  // Update graph and grid
  updateGraph(startIndex, endIndex)
  updateGrid(startIndex, endIndex)
}

// Moves the slider automatically after a delay
let timeout
const autoUpdate = () => {
  // Doubleminus-Trick to convert value to number
  SVG('input').node.value -= -0.01

  handleSlider()
  timeout = setTimeout(autoUpdate, 1000)
}

// Bind event and initialize chart
SVG('input').on('input', handleSlider)
handleSlider()

// Set the timeout to start autoupdates
timeout = setTimeout(autoUpdate, 1000)
