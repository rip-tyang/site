var cmargin = {top: 0, right: 0, bottom: 75, left: 60},
    cwidth = 1000 - cmargin.left - cmargin.right,
    cheight = 180 - cmargin.top - cmargin.bottom;

var s_x = d3.scale.ordinal()
    .rangeRoundBands([0, cwidth], .1, 1),
    d_x = d3.scale.ordinal()
    .rangeRoundBands([0, cwidth], .1, 1);

var s_y = d3.scale.log()
    .range([cheight, 0]),
    d_y = d3.scale.log()
    .range([cheight, 0]);

var s_xAxis = d3.svg.axis()
    .scale(s_x)
    .orient("bottom"),
    d_xAxis = d3.svg.axis()
    .scale(d_x)
    .orient("bottom");

var s_yAxis = d3.svg.axis()
    .scale(s_y)
    .orient("left")
    .tickFormat(d3.format("d"))
    .tickValues([1,10,100,1000,10000]),
    d_yAxis = d3.svg.axis()
    .scale(d_y)
    .orient("left")
    .tickFormat(d3.format("d"))
    .tickValues([1,10,100,1000,10000]);

var s_svg = d3.select(".bar_chart").append("p").append("svg")
    .attr("width", cwidth + cmargin.left + cmargin.right)
    .attr("height", cheight + cmargin.top + cmargin.bottom)
  .append("g")
    .attr("transform", "translate(" + cmargin.left + "," + cmargin.top + ")"),
d_svg = d3.select(".bar_chart").append("p").append("svg")
    .attr("width", cwidth + cmargin.left + cmargin.right)
    .attr("height", cheight + cmargin.top + cmargin.bottom)
  .append("g")
    .attr("transform", "translate(" + cmargin.left + "," + cmargin.top + ")");

var sdata, ddata;

var sx = s_svg.append("g")
  .attr("class", "sx axis")
  .attr("transform", "translate(0," + cheight + ")"),
  dx = d_svg.append("g")
  .attr("class", "dx axis")
  .attr("transform", "translate(0," + cheight + ")"),
  sy = s_svg.append("g")
  .attr("class", "sy axis"),
  dy = d_svg.append("g")
  .attr("class", "dy axis");

var s_sortTimeout = setTimeout(function() {
    d3.select(".s_input").property("checked", true).each(schange);
  }, 2000);

var d_sortTimeout = setTimeout(function() {
    d3.select(".d_input").property("checked", true).each(dchange);
  }, 2000);
function load_barchart_data() {
  for( var i =0; i < 3; ++i ){
    if(0 == $($("g.dimension text tspan.name")[i]).text().search(/source/))
      sdata = $($("g.dimension")[i]).attr("transform");
    if(0 == $($("g.dimension text tspan.name")[i]).text().search(/dest./))
      ddata = $($("g.dimension")[i]).attr("transform");
  }
  f = function(e, i) {
    return {
      "letter": $(e).children("text").attr("name"),
      "frequency": $(e).attr("total")
    };
  };
  sdata = $("g.dimension[transform='"+sdata+"'] g").toArray().map(f);
  ddata = $("g.dimension[transform='"+ddata+"'] g").toArray().map(f);
  draw();
}

function draw() {
  s_x.domain(sdata.map(function(d) { return d.letter; }));
  s_y.domain([1, 30000]);
  sx.call(s_xAxis);
  sy.call(s_yAxis);


  d_x.domain(ddata.map(function(d) { return d.letter; }));
  d_y.domain([1, 30000]);
  dy.call(d_yAxis);
  dx.call(d_xAxis);

  s_svg.selectAll(".s_bar").remove();
  s_svg.selectAll(".s_bar")
      .data(sdata)
    .enter().append("rect")
      .attr("class", "s_bar")
      .attr("x", function(d) { return s_x(d.letter); })
      .attr("width", s_x.rangeBand())
      .attr("y", function(d) { return s_y(d.frequency); })
      .attr("height", function(d) { return cheight - s_y(d.frequency); });

  s_svg.selectAll(".s_bar")
      .data(sdata)
    .exit().remove();

  d_svg.selectAll(".d_bar").remove();
  d_svg.selectAll(".d_bar")
      .data(ddata)
    .enter().append("rect")
      .attr("class", "d_bar")
      .attr("x", function(d) { return d_x(d.letter); })
      .attr("width", d_x.rangeBand())
      .attr("y", function(d) { return d_y(d.frequency); })
      .attr("height", function(d) { return cheight - d_y(d.frequency); });

  d_svg.selectAll(".d_bar")
      .data(ddata)
    .exit().remove();
  d3.selectAll(".dx.axis .tick.major text").style("text-anchor", "start");
  d3.selectAll(".sx.axis .tick.major text").style("text-anchor", "start");
  if( sdata.length > 80 )
    d3.selectAll(".sx.axis text").style("font-size", "4px");
  else if( sdata.length > 40 )
    d3.selectAll(".sx.axis text").style("font-size", "8px");
  else if( sdata.length > 20 )
    d3.selectAll(".sx.axis text").style("font-size", "10px");
  else
    d3.selectAll(".sx.axis text").style("font-size", "18px");
  if( ddata.length > 80 )
    d3.selectAll(".dx.axis text").style("font-size", "4px");
  else if( ddata.length > 40 )
    d3.selectAll(".dx.axis text").style("font-size", "8px");
  else if( ddata.length > 20 )
    d3.selectAll(".dx.axis text").style("font-size", "10px");
  else
    d3.selectAll(".dx.axis text").style("font-size", "18px");
  d3.select(".s_input").on("change", schange);
  d3.select(".d_input").on("change", dchange);
}

function schange() {
  clearTimeout(s_sortTimeout);
  // Copy-on-write since tweens are evaluated after a delay.
  var x0 = s_x.domain(sdata.sort(this.checked
      ? function(a, b) { return b.frequency - a.frequency; }
      : function(a, b) { return d3.ascending(a.letter, b.letter); })
      .map(function(d) { return d.letter; }))
      .copy();

  var transition = s_svg.transition().duration(750),
      delay = function(d, i) { return i * 50; };

  transition.selectAll(".s_bar")
      .delay(delay)
      .attr("x", function(d) { return x0(d.letter); });

  transition.select(".sx.axis")
      .call(s_xAxis)
    .selectAll("g")
      .delay(delay)
  d3.selectAll(".sx.axis .tick.major text").style("text-anchor", "start");
}

function dchange() {
  clearTimeout(d_sortTimeout);
  // Copy-on-write since tweens are evaluated after a delay.
  var x0 = d_x.domain(ddata.sort(this.checked
      ? function(a, b) { return b.frequency - a.frequency; }
      : function(a, b) { return d3.ascending(a.letter, b.letter); })
      .map(function(d) { return d.letter; }))
      .copy();

  var transition = d_svg.transition().duration(750),
      delay = function(d, i) { return i * 50; };

  transition.selectAll(".d_bar")
      .delay(delay)
      .attr("x", function(d) { return x0(d.letter); });

  transition.select(".dx.axis")
      .call(d_xAxis)
    .selectAll("g")
      .delay(delay)
  d3.selectAll(".dx.axis .tick.major text").style("text-anchor", "start");
}