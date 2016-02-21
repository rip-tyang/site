var geo_data_flag = false,
  passenger_data_flag = false;

var global_geo_dataset = [],
  cur_dataset = [],
  departure_dataset = [],
  statistic_dataset = [],
  global_passenger_dataset = [],
  passenger_map = {},
  content = {
    'vessel': ['Go Fast', 'Rustic', 'Raft'],
    'record': ['Interdiction', 'Landing'],
    'year': [2005, 2006, 2007],
    'month': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    'week': [0, 1, 2, 3, 4, 5, 6],
    'death': ['Alive', 'Death']
  },
  color_pattern = d3.scale.category10(),
  test_color_pattern = d3.scale.category20(),
  filter = {
    record: null,
    vessel: null,
    year: null,
    month: null,
    week: null,
    day: null
  };

// map options
var map_margin = {top: 0, right: 0, bottom: 0, left: 0},
  map_width = 500 - map_margin.left - map_margin.right,
  map_height = 350 - map_margin.top - map_margin.bottom;

// chart options
var chart_margin = {top: 20, right: 20, bottom: 30, left: 50},
  chart_width = 500 - chart_margin.left - chart_margin.right,
  chart_height = 350 - chart_margin.top - chart_margin.bottom;

// landing map
var landing_map_la_scale = d3.scale.linear()
    .range([map_height, 0])
    .domain([19.80, 29.20]),
  landing_map_lo_scale = d3.scale.linear()
    .range([0, map_width])
    .domain([-91.91, -77.7]),
  landing_color_var = 'vessel',
  landing_size_var = null,
  landing_size_scale = d3.scale.linear().range([1.5, 7]),
  landing_map_now;

// departure map
var departure_map_la_scale = d3.scale.linear()
    .range([map_height, 0])
    .domain([23.42, 24.14]),
  departure_map_lo_scale = d3.scale.linear()
    .range([-70, map_width-70])
    .domain([-80.64, -79.55]),
  departure_color_var = 'vessel',
  departure_size_var = null,
  departure_size_scale = d3.scale.linear().range([1.5, 7]),
  departure_map_now;

// histogram
var histogram_x_scale = d3.scale.ordinal()
    .range([0, chart_width])
    .rangeRoundBands([0, chart_width], .08),
  histogram_y_scale = d3.scale.linear().range([chart_height, 0]),
  histogram_xAxis = d3.svg.axis()
    .scale(histogram_x_scale)
    .orient("bottom"),
  histogram_yAxis = d3.svg.axis()
    .scale(histogram_y_scale)
    .orient("left"),
  histogram_x_var = 'month',
  histogram_y_var = 'persons',
  histogram_stack_var = 'vessel',
  histogram_view_var = 'Stacked',
  histogram_stack = d3.layout.stack(),
  histogram_layers,
  histogram_now_layer,
  histogram_now_rect,
  histogramYStackMax,
  histogramYGroupMax;

// scatter graph
var scatter_x_scale = d3.time.scale().range([0, chart_width]),
  scatter_y_scale = d3.scale.linear().range([chart_height, 0]),
  scatter_size_scale = d3.scale.linear().range([1.5, 7]),
  scatter_xAxis = d3.svg.axis()
    .scale(scatter_x_scale)
    .orient("bottom")
    .tickFormat(d3.time.format('%Y'))
    .ticks(4),
  scatter_yAxis = d3.svg.axis()
    .scale(scatter_y_scale)
    .orient("left"),
  scatter_y_var = 'persons',
  scatter_color_var = 'vessel',
  scatter_size_var = null,
  scatter_now;

// map prepare
var landing_map = d3.select('svg#mapView')
  .append("g")
    .attr("transform",
      "translate(" + map_margin.left + "," + map_margin.top + ")")
    .attr('class', 'landing'),
  departure_map = d3.select('svg#mapView')
    .append('g')
      .attr('transform',
        'translate(' +
          (map_width + 2*map_margin.left + map_margin.right+20) +
          ',' + map_margin.top + ')')
      .attr('class', 'departure');
  landing_map.append('line')
    .attr('x1', 520)
    .attr('x2', 520)
    .attr('y1', 0)
    .attr('y2', 350)
    .style('stroke', '#eee')
    .style('stroke-width', '5px');
// chart prepare
var histogram = d3.select("svg#chartView")
  .append("g")
    .attr('transform',
        'translate(' + chart_margin.left + ',' + chart_margin.top + ')')
    .attr('class', 'bar'),
  scatter_graph = d3.select('svg#chartView')
    .append('g')
      .attr("transform",
        "translate(" +
        (chart_width + 2*chart_margin.left + chart_margin.right+20) +
        "," + chart_margin.top + ")")
      .attr('class', 'scatter');

// descriptive window click to hide
  $descriptive.find('.icon').on('click', function(d) {
  $descriptive.addClass('hidden');
  $descriptive.removeClass('landing');
  $descriptive.removeClass('departure');
  if (d3.selectAll('.dot.active').data()[0]) {
    d3.selectAll('.dot.active').data()[0].active = false;
  }
  d3.selectAll('.dot.active')
    .attr('class', 'dot')
    .transition()
    .duration(500)
    .style("fill", function (d) {
      return color_pattern(d[scatter_color_var]);
    })
    .attr('r', function (d) {
      if (scatter_size_var) {
        return scatter_size_scale(d[scatter_size_var]);
      }
      return 2.5;
    });
});

/**
 * Load Data
 */
function read_data() {
  d3.csv("data/geo_information.csv", function (d, i) {
    var to_return = {
      ID: i,
      ships: 1,
      time: new Date(+d.Year, +d.Month-1, +d.Day),
      year: +d.Year,
      month: +d.Month,
      day: +d.Day,
      week: new Date(+d.Year, +d.Month-1, +d.Day).getDay(),
      persons: +d.Amount,
      deaths: +d.Death,
      rate: (+d.Death)/(+d.Amount),
      l_lo: +d.L_Longitude,
      l_la: +d.L_Latitude,
      d_lo: +d.D_Longitude,
      d_la: +d.D_Latitude,
      vessel: d.Vessel,
      record: d.Record,
      USCG: d.USCG,
      active: false,
    };
    if (to_return.d_lo !== 0.0) departure_dataset.push(to_return);
    return to_return;
  }, function (errors, rows) {
    cur_dataset = global_geo_dataset = rows;
    scatter_x_scale.domain([new Date(2005,0,1), new Date(2008,0,1)]);
    scatter_y_scale.domain(d3.extent(rows, function(d) {
      return d[scatter_y_var];
    }));
    geo_data_flag = true;
  });

  d3.csv("data/passenger_information.csv", function (d) {
    if (undefined === global_passenger_dataset[+d.ID]) {
      global_passenger_dataset[+d.ID] = [];
    }
    global_passenger_dataset[+d.ID].push( d.names );
    passenger_map[d.names] = +d.ID;
  }, function (errors, rows) {
    passenger_data_flag = true;
  });
}

/**
 * To give out a statistic result
 */
function statistic_preprocessing() {
  var stack_index,
    x_index;
  if (histogram_stack_var !== 'death') {
    statistic_dataset = d3.range(content[histogram_stack_var].length);
    statistic_dataset = statistic_dataset.map(function (d, i) {
      var t = [];
      t.name = content[histogram_stack_var][i];
      return t;
    });
  }
  else {
    statistic_dataset = [[], []];
    statistic_dataset[0].name = content.death[0];
    statistic_dataset[1].name = content.death[1];
  }

  for (var j in statistic_dataset) {
    for (var k in content[histogram_x_var]) {
      statistic_dataset[j].push({x: content[histogram_x_var][k], y: 0});
    }
  }
  for (var i in cur_dataset) {
    if (histogram_stack_var !== 'death') {
      stack_index = content[histogram_stack_var].indexOf(
        cur_dataset[i][histogram_stack_var]
      );
      x_index = content[histogram_x_var].indexOf(
        cur_dataset[i][histogram_x_var]
      );
      statistic_dataset[stack_index][x_index].y +=
        cur_dataset[i][histogram_y_var];

// death rate is an average amount give it a hack
      if (histogram_y_var === 'rate') {
        if (!statistic_dataset[stack_index][x_index].z) {
          statistic_dataset[stack_index][x_index].z = 0;
        }
        statistic_dataset[stack_index][x_index].z +=
          cur_dataset[i].ships;
      }
    }
    else {
      x_index = content[histogram_x_var].indexOf(
        cur_dataset[i][histogram_x_var]
      );
      statistic_dataset[0][x_index].y +=
        (cur_dataset[i].persons-cur_dataset[i].deaths);
      statistic_dataset[1][x_index].y += cur_dataset[i].deaths;
    }
  }

// death rate is an average amount give it a hack
  if (histogram_y_var === 'rate') {
    for (var m in statistic_dataset) {
      for (var n in statistic_dataset[m]) {
        statistic_dataset[m][n].y /= statistic_dataset[m][n].z;
      }
    }
  }
  histogram_layers = histogram_stack(statistic_dataset);
  histogramYGroupMax = d3.max(histogram_layers, function(layer) {
    return d3.max(layer, function(d) { return d.y; });
  });
  histogramYStackMax = d3.max(histogram_layers, function(layer) {
    return d3.max(layer, function(d) { return d.y0 + d.y; });
  });
  histogram_x_scale.domain(content[histogram_x_var]);
  if (histogram_view_var === 'Stacked') {
    histogram_y_scale.domain([0, histogramYStackMax*1.1]);
  }
  else {
    histogram_y_scale.domain([0, histogramYGroupMax*1.1]);
  }
}

/**
 * Redraw the chart
 */
function redraw(f, arg) {

// delete target line
    $('line.target').remove();
// data adjustment
// may take a lot of time
  if (f === undefined || f === 'nofilter') {
    if (f === undefined) filterfunc();
// landing map part
// append map
    landing_map_now = landing_map.selectAll(".dot")
      .data(cur_dataset, function (d) { return d.ID; });
    landing_map_now
      .enter()
        .append("circle")
        .attr("class", "dot")
        .attr('index', function (d) { return d.ID; })
        .attr("r", 0)
        .attr("cx", function (d) { return landing_map_lo_scale(d.l_lo); })
        .attr("cy", function (d) { return landing_map_la_scale(d.l_la); })
        .style("fill", function (d) {
          return color_pattern(d[landing_color_var]);
        })
      .transition()
        .duration(1000)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', function (d) {
          if (landing_size_var) {
            return landing_size_scale(d[landing_size_var]);
          }
          return 2.5;
        });
    landing_map_now
      .exit()
        .transition()
        .duration(1000)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', 0)
        .each('end', function (d) {
          this.remove();
        });
    if (f === 'nofilter') {
      redraw('landingLegend');
    }

// departure map part
// appending map
    departure_map_now = departure_map.selectAll(".dot")
      .data(departure_dataset, function (d) { return d.ID; });
    departure_map_now
      .enter()
        .append("circle")
        .attr("class", "dot")
        .attr('index', function (d) { return d.ID; })
        .attr("r", 0)
        .attr("cx", function (d) { return departure_map_lo_scale(d.d_lo); })
        .attr("cy", function (d) { return departure_map_la_scale(d.d_la); })
        .style("fill", function (d) {
          return color_pattern(d[departure_color_var]);
        })
      .transition()
        .duration(1000)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', function (d) {
          if (departure_size_var) {
            return departure_size_scale(d[departure_size_var]);
          }
          return 2.5;
        });
    departure_map_now
      .exit()
        .transition()
        .duration(1000)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', 0)
        .each('end', function (d) {
          this.remove();
        });
    if (f === 'nofilter') {
      redraw('departureLegend');
    }

// scatter graph part
// append chart
    if (f === 'nofilter') {
      scatter_graph.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + chart_height + ")")
          .call(scatter_xAxis)
        .append("text")
          .attr("class", "label")
          .attr("x", chart_width-50)
          .attr("y", 20)
          .style("text-anchor", "end")
          .text("time");

      scatter_graph.append("g")
          .attr("class", "y axis")
          .call(scatter_yAxis)
        .append("text")
          .attr("class", "label")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr('x', -10)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text(scatter_y_var);
    }

// unbind old interaction event
    $('.dot').off('mouseover');
    $('.dot').off('mouseleave');
    $('.dot').off('click');
    $('.dot').popup('remove');

// handle points
    scatter_now = scatter_graph.selectAll(".dot")
      .data(cur_dataset, function (d) { return d.ID; });
    scatter_now
      .enter()
        .append("circle")
        .attr("class", "dot")
        .attr('index', function (d) { return d.ID; })
        .attr("r", 0)
        .attr("cx", function (d) { return scatter_x_scale(d.time); })
        .attr("cy", function (d) { return scatter_y_scale(d[scatter_y_var]); })
        .style("fill", function (d) {
          return color_pattern(d[scatter_color_var]);
        })
      .transition()
        .duration(500)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', function (d) {
          if (scatter_size_var) {
            return scatter_size_scale(d[scatter_size_var]);
          }
          return 2.5;
        });
    scatter_now
      .exit()
        .transition()
        .duration(500)
        .delay( function (d, i) {
          return 500+1*i;
        })
        .attr('r', 0)
        .each('end', function (d) {
          this.remove();
        });

// scatter graph dot interaction
    $('.dot').popup({
      debug: false,
      verbose: false,
      delay: 1500,
      content: 'Click to see details'
    });
    $('.dot').on('mouseover', function (d) {
      if ($(this).parent().attr('class') == 'landing') {
        d3.select(this)
          .transition()
          .duration(200)
          .style('fill', '#333')
          .attr('r', function (d) {
            if (landing_size_var) {
              return 4+landing_size_scale(d[landing_size_var]);
            }
            return 6.5;
          });
      }
      else if ($(this).parent().attr('class') == 'departure') {
        d3.select(this)
          .transition()
          .duration(200)
          .style('fill', '#333')
          .attr('r', function (d) {
            if (departure_size_var) {
              return 4+departure_size_scale(d[landing_size_var]);
            }
            return 6.5;
          });
      }
      else {
        d3.select(this)
          .transition()
          .duration(200)
          .style('fill', '#333')
          .attr('r', function (d) {
            if (scatter_size_var) {
              return 4+scatter_size_scale(d[scatter_size_var]);
            }
            return 6.5;
          });
      }
    });
    $('.dot').on('mouseleave', function (d) {
      if ($(this).attr('class').length>3) return;
      if ($(this).parent().attr('class') == 'landing') {
        d3.select(this)
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[landing_color_var]);
          })
          .attr('r', function (d) {
            if (landing_size_var) {
              return landing_size_scale(d[landing_size_var]);
            }
            return 2.5;
          });
      }
      else if ($(this).parent().attr('class') == 'departure'){
        d3.select(this)
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[departure_color_var]);
          })
          .attr('r', function (d) {
            if (departure_size_var) {
              return departure_size_scale(d[departure_size_var]);
            }
            return 2.5;
          });
      }
      else {
        d3.select(this)
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[scatter_color_var]);
          })
          .attr('r', function (d) {
            if (scatter_size_var) {
              return scatter_size_scale(d[scatter_size_var]);
            }
            return 2.5;
          });
      }
    });
    $('.dot').on('click', function (d) {
      var $this = $(this),
        i = $this.attr('index'),
        t = global_geo_dataset[i],
        names = global_passenger_dataset[i],
        strnames = '';

// other dot refresh
      if (d3.select('.dot.active').data()[0]) {
        d3.select('.dot.active').data()[0].active = false;
      }
      if ($this.parent().attr('class') == 'landing') {
        d3.selectAll('.dot.active')
          .attr('class', 'dot')
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[landing_color_var]);
          })
          .attr('r', function (d) {
            if (landing_size_var) {
              return landing_size_scale(d[landing_size_var]);
            }
            return 2.5;
          });
      }
      else if ($this.parent().attr('class') == 'departure') {
        d3.selectAll('.dot.active')
          .attr('class', 'dot')
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[departure_color_var]);
          })
          .attr('r', function (d) {
            if (departure_size_var) {
              return departure_size_scale(d[departure_size_var]);
            }
            return 2.5;
          });
      }
      else {
        d3.selectAll('.dot.active')
          .attr('class', 'dot')
          .transition()
          .duration(500)
          .style("fill", function (d) {
            return color_pattern(d[scatter_color_var]);
          })
          .attr('r', function (d) {
            if (scatter_size_var) {
              return scatter_size_scale(d[scatter_size_var]);
            }
            return 2.5;
          });
      }
      $('circle[index="'+i+'"]').attr('class', 'dot active');
      d3.selectAll('circle[index="'+i+'"]')
        .data()[0].active = true;

// descriptive window pop out
      if (names !== undefined) strnames = names.join('</li><li>');
      else strnames = 'No Data';
      $descriptive.removeClass('landing');
      $descriptive.removeClass('departure');
      if ($this.parent().attr('class') == 'landing') {
        $descriptive.addClass('landing');
      }
      else if ($this.parent().attr('class') == 'departure') {
        $descriptive.addClass('departure');
      }
      $descriptive.find('p').remove();
      $descriptive.find('ul').remove();
      $descriptive.append('<p><b>Time: </b>'+t.year+'/'+t.month+'/'+t.day+'</p>');
      $descriptive.append('<p><b>USCG: </b>'+t.USCG+'</p>');
      $descriptive.append('<p><b>Record: </b>'+t.record+'</p>');
      $descriptive.append('<p><b>Vessel: </b>'+t.vessel+'</p>');
      $descriptive.append('<p><b>Persons: </b>'+t.persons+'</p>');
      $descriptive.append('<p><b>Deaths: </b>'+t.deaths+'</p>');
      $descriptive.append('<p><b>Passengers: </b></p><ul class="fly"><li>' + strnames + '</li></ul>');
      $descriptive.removeClass('hidden');
//TODO stroll effect
    });
    if (f === 'nofilter') redraw('scatterLegend');

// histogram part
// appending chart
    statistic_preprocessing();
    if (f === 'nofilter') {
      histogram.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + chart_height + ')')
          .call(histogram_xAxis)
        .append('text')
          .attr('class', 'label')
          .attr('x', chart_width+30)
          .attr('y', 20)
          .style('text-anchor', 'end')
          .text(histogram_x_var);
    }
    $('.bar .y.axis').remove();
    histogram.append("g")
        .attr("class", "y axis")
        .call(histogram_yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr('x', -10)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(histogram_y_var);
    if (f==='nofilter') {
      histogram_now_layer = histogram.selectAll(".layer")
        .data(histogram_layers, function (d) { return d.name; })
        .enter()
          .append("g")
            .attr("class", "layer")
            .style('fill', function (d, i) {
              return color_pattern(content[histogram_stack_var][i]);
            });

// appending rect
      histogram_now_rect = histogram_now_layer.selectAll('rect')
        .data(function (d) { return d; });
      histogram_now_rect
        .enter()
          .append("rect")
            .attr("x", function(d) { return histogram_x_scale(d.x); })
            .attr("y", chart_height)
            .attr("width", histogram_x_scale.rangeBand())
            .attr("height", 0);
      histogram_now_rect
        .transition()
          .duration(500)
          .delay(function (d, i) { return i * 20; })
          .attr("y", function (d) {
            return histogram_y_scale(d.y0 + d.y);
          })
          .attr("height", function (d) {
            return histogram_y_scale(d.y0) - histogram_y_scale(d.y0 + d.y);
          });

// rect interaction
      histogram_now_rect.on('mouseover', function (d) {
        var tclass = $(this).attr('class');
        $(this).attr('class', tclass+' hover');
      });
      histogram_now_rect.on('mouseleave', function (d) {
        var tclass = $(this).attr('class').split(' '),
          result = '';
        for (var i in tclass) {
          if (tclass[i] === 'hover') continue;
          else {
            result = result + tclass[i] + ' ';
          }
        }
        $(this).attr('class', result.slice(0, result.length-1));
      });
    }
    else {
      histogram_now_layer.data(histogram_layers, function (d) {
        return d.name;
      });
      histogram_now_rect = histogram_now_layer.selectAll('rect')
        .data(function (d) { return d; });
      if (histogram_view_var === 'Stacked') {
          histogram_now_rect
            .transition()
              .duration(500)
              .delay(function (d, i) { return i * 20; })
              .attr("y", function (d) {
                return histogram_y_scale(d.y0 + d.y);
              })
              .attr("height", function (d) {
                return histogram_y_scale(d.y0) - histogram_y_scale(d.y0 + d.y);
              });
        }
        else {
          histogram_now_rect
            .transition()
              .duration(500)
              .delay(function (d, i) { return i * 20; })
              .attr("y", function (d) { return histogram_y_scale(d.y); })
              .attr("height", function (d) {
                return chart_height - histogram_y_scale(d.y);
              });
        }
    }

    if (f==='nofilter') redraw('histogramLegend');
    return;
  }

// scatter graph y axis adjustment
  if (f === 'scatterYControl') {
    if (scatter_y_var === arg) return;
    scatter_y_var = arg;
    $('.scatter .y.axis').remove();
    scatter_y_scale.domain(d3.extent(cur_dataset, function(d) {
      return d[scatter_y_var];
    }));
    scatter_yAxis = d3.svg.axis()
      .scale(scatter_y_scale)
      .orient("left");
    scatter_graph.append("g")
        .attr("class", "y axis")
        .call(scatter_yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr('x', -10)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(scatter_y_var);
    scatter_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .attr('cy', function (d) { return scatter_y_scale(d[scatter_y_var]); });
    return;
  }

// scatter graph color pattern adjustment
  if (f==='scatterColor') {
    if (scatter_color_var === arg) return;
    scatter_color_var = arg;
    scatter_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .style('fill', function (d) {
        if (!d.active) return color_pattern(d[scatter_color_var]);
      });
    $('.scatter .legend').remove();
    legend = scatter_graph.append("g")
      .attr("class", "legend");
    redraw('scatterLegend');
    return;
  }

// redraw legend
  if (f === 'scatterLegend') {
    var legend;
    legend = scatter_graph.append("g")
      .attr("class", "legend");
    for (var k in content[scatter_color_var]) {
      legend.append('rect')
        .attr('x', 8+k*100)
        .attr('y', -14)
        .attr('height', 10)
        .attr('width', 10)
        .style('fill', function (d) {
          return color_pattern(content[scatter_color_var][k]);
        });
      legend.append('text')
        .attr("class", "label")
        .attr('x', 20+k*100)
        .attr('y', -15)
        .attr("dy", ".71em")
        .text(content[scatter_color_var][k]);
    }
    return;
  }

  if (f === 'histogramLegend') {
    var legend;
    $('.bar .legend').remove();
    legend = histogram.append("g")
      .attr("class", "legend");
    for (var k in content[histogram_stack_var]) {
      legend.append('rect')
        .attr('x', 8+k*100)
        .attr('y', -14)
        .attr('height', 10)
        .attr('width', 10)
        .style('fill', function (d) {
          return color_pattern(content[histogram_stack_var][k]);
        });
      legend.append('text')
        .attr("class", "label")
        .attr('x', 20+k*100)
        .attr('y', -15)
        .attr("dy", ".71em")
        .text(content[histogram_stack_var][k]);
    }
    return;
  }

  if (f === 'landingLegend') {
    var legend;
    legend = landing_map.append("g")
      .attr("class", "legend");
    for (var k in content[landing_color_var]) {
      legend.append('rect')
        .attr('x', 30+k*100)
        .attr('y', 51)
        .attr('height', 10)
        .attr('width', 10)
        .style('fill', function (d) {
          return color_pattern(content[landing_color_var][k]);
        });
      legend.append('text')
        .attr("class", "label")
        .attr('x', 42+k*100)
        .attr('y', 50)
        .attr("dy", ".71em")
        .text(content[landing_color_var][k]);
    }
    return;
  }

  if (f === 'departureLegend') {
    var legend;
    legend = departure_map.append("g")
      .attr("class", "legend");
    for (var k in content[departure_color_var]) {
      legend.append('rect')
        .attr('x', 60+k*100)
        .attr('y', 301)
        .attr('height', 10)
        .attr('width', 10)
        .style('fill', function (d) {
          return color_pattern(content[departure_color_var][k]);
        });
      legend.append('text')
        .attr("class", "label")
        .attr('x', 72+k*100)
        .attr('y', 300)
        .attr("dy", ".71em")
        .text(content[departure_color_var][k]);
    }
    return;
  }

// scatter graph size adjustment
  if (f==='scatterSize') {
    if (scatter_size_var === arg) return;
    scatter_size_var = arg;
    scatter_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .attr('r', function (d) {
        if (scatter_size_var) {
          if (!d.active) {
            return scatter_size_scale(d[scatter_size_var]);
          }
          else return 4+scatter_size_scale(d[scatter_size_var]);
        }
        if (!d.active) return 2.5;
        else return 6.5;
      });
    return;
  }

// histogram x axis adjustment
  if (f==='histogramXControl') {
    var counter = content[histogram_x_var].length*
      content[histogram_stack_var].length;

    if (histogram_x_var === arg) return;
    histogram_x_var = arg;
    statistic_preprocessing();
    histogram_now_rect
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 20*i;
      })
      .attr('y', chart_height)
      .attr('height', 0)
      .each('end', function (d) {
        counter -= 1;
        if (counter>0) return;
        $('.bar .axis').remove();
        histogram.append('g')
            .attr('class', 'x axis')
            .attr('transform', 'translate(0,' + chart_height + ')')
            .call(histogram_xAxis)
          .append('text')
            .attr('class', 'label')
            .attr('x', chart_width+30)
            .attr('y', 20)
            .style('text-anchor', 'end')
            .text(histogram_x_var);
        histogram.append("g")
            .attr("class", "y axis")
            .call(histogram_yAxis)
          .append("text")
            .attr("class", "label")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr('x', -10)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(histogram_y_var);
        histogram_now_layer.remove();
        histogram_now_layer = histogram.selectAll('.layer')
          .data(histogram_layers, function (d) { return d.name; });
        histogram_now_layer
          .enter()
            .append("g")
              .attr("class", "layer")
              .style('fill', function (d, i) {
                return color_pattern(content[histogram_stack_var][i]);
              });
        histogram_now_rect = histogram_now_layer.selectAll('rect')
          .data(function (d) { return d; });
        if (histogram_view_var === 'Stacked') {
          histogram_now_rect
            .enter()
              .append("rect")
                .attr("x", function(d) { return histogram_x_scale(d.x); })
                .attr("y", chart_height)
                .attr("width", histogram_x_scale.rangeBand())
                .attr("height", 0);
          histogram_now_rect
            .transition()
              .duration(500)
              .delay(function (d, i) { return i * 20; })
              .attr("y", function (d) {
                return histogram_y_scale(d.y0 + d.y);
              })
              .attr("height", function (d) {
                return histogram_y_scale(d.y0) - histogram_y_scale(d.y0 + d.y);
              });
        }
        else {
          histogram_now_rect
            .enter()
            .append('rect')
              .attr("x", function (d, i, j) {
                return histogram_x_scale(d.x) +
                  histogram_x_scale.rangeBand() /
                  content[histogram_stack_var].length * j;
              })
              .attr("width", histogram_x_scale.rangeBand() /
                content[histogram_stack_var].length)
              .attr('height', 0)
              .attr('y', chart_height)
            .transition()
              .duration(500)
              .delay(function (d, i) { return i * 20; })
              .attr("y", function (d) { return histogram_y_scale(d.y); })
              .attr("height", function (d) {
                return chart_height - histogram_y_scale(d.y);
              });
        }

// rect interaction
        histogram_now_rect.on('mouseover', function (d) {
          var tclass = $(this).attr('class');
          $(this).attr('class', tclass+' hover');
        });
        histogram_now_rect.on('mouseleave', function (d) {
          var tclass = $(this).attr('class').split(' '),
            result = '';
          for (var i in tclass) {
            if (tclass[i] === 'hover') continue;
            else {
              result = result + tclass[i] + ' ';
            }
          }
          $(this).attr('class', result.slice(0, result.length-1));
        });
      });
    return;
  }

// histogram y axis adjustment
  if (f==='histogramYControl') {
    if (histogram_y_var === arg) return;
    histogram_y_var = arg;
    statistic_preprocessing();
    $('.bar .y.axis').remove();
    histogram.append("g")
        .attr("class", "y axis")
        .call(histogram_yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr('x', -10)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(histogram_y_var);
    histogram_now_layer.data(histogram_layers, function (d) {
      return d.name;
    });
    histogram_now_rect = histogram_now_layer.selectAll('rect')
      .data( function (d) { return d; } );
    if (histogram_view_var === 'Stacked') {
      histogram_now_rect
        .transition()
        .duration(500)
        .delay(function (d, i) { return i*20; })
        .attr('y', function (d) {
          return histogram_y_scale(d.y0+d.y);
        })
        .attr('height', function (d) {
          return histogram_y_scale(d.y0)-histogram_y_scale(d.y0+d.y);
        });
    }
    else {
      histogram_now_rect
        .transition()
          .duration(500)
          .delay(function (d, i) { return i * 20; })
          .attr("x", function (d, i, j) {
            return histogram_x_scale(d.x) +
              histogram_x_scale.rangeBand() /
              content[histogram_stack_var].length * j;
          })
          .attr("width", histogram_x_scale.rangeBand() /
            content[histogram_stack_var].length)
        .transition()
          .attr("y", function (d) { return histogram_y_scale(d.y); })
          .attr("height", function (d) {
            return chart_height - histogram_y_scale(d.y);
          });
    }
    return;
  }

// histogram stack adjustment
  if (f==='histogramStack') {
    var counter = content[histogram_x_var].length*
        content[histogram_stack_var].length;

    if (histogram_stack_var === arg) return;
    histogram_stack_var = arg;

  // if stack is 'death' change y axis to persons mode
    if (histogram_stack_var === 'death' || histogram_stack_var === 'record') {
      if (histogram_stack_var === 'death') {
        histogram_y_var = 'persons';
        $('.histogram.yControl div.text').text('Persons');
      }
      if (histogram_stack_var === 'record') {
        histogram_y_var = 'ships';
        $('.histogram.yControl div.text').text('Ships');
      }
      statistic_preprocessing();
      $('.bar .y.axis').remove();
      histogram.append("g")
          .attr("class", "y axis")
          .call(histogram_yAxis)
        .append("text")
          .attr("class", "label")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr('x', -10)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text(histogram_y_var);
    }
    else statistic_preprocessing();
    histogram_now_rect
        .transition()
        .duration(500)
        .delay( function (d, i) {
          return 20*i;
        })
        .attr('y', chart_height)
        .attr('height', 0)
        .each('end', function (d) {
          counter -= 1;
          if (counter>0) return;
          histogram_now_layer.remove();
          histogram_now_layer = histogram.selectAll('.layer')
            .data(histogram_layers, function (d) { return d.name; });
          histogram_now_layer
            .enter()
              .append("g")
                .attr("class", "layer")
                .style('fill', function (d, i) {
                  return color_pattern(content[histogram_stack_var][i]);
                });
          histogram_now_rect = histogram_now_layer.selectAll('rect')
            .data(function (d) { return d; });
          if (histogram_view_var === 'Stacked') {
            histogram_now_rect
              .enter()
                .append("rect")
                  .attr("x", function(d) { return histogram_x_scale(d.x); })
                  .attr("y", chart_height)
                  .attr("width", histogram_x_scale.rangeBand())
                  .attr("height", 0);
            histogram_now_rect
              .transition()
                .duration(500)
                .delay(function (d, i) { return i * 20; })
                .attr("y", function (d) {
                  return histogram_y_scale(d.y0 + d.y);
                })
                .attr("height", function (d) {
                  return histogram_y_scale(d.y0) -
                    histogram_y_scale(d.y0 + d.y);
                });
          }
          else {
            histogram_now_rect
              .enter()
              .append('rect')
                .attr("x", function (d, i, j) {
                  return histogram_x_scale(d.x) +
                    histogram_x_scale.rangeBand() /
                    content[histogram_stack_var].length * j;
                })
                .attr("width", histogram_x_scale.rangeBand() /
                  content[histogram_stack_var].length)
                .attr('y', chart_height)
                .attr('height', 0)
              .transition()
                .duration(500)
                .delay(function (d, i) { return i * 20; })
                .attr("y", function (d) { return histogram_y_scale(d.y); })
                .attr("height", function (d) {
                  return chart_height - histogram_y_scale(d.y);
                });
          }

// rect interaction
          histogram_now_rect.on('mouseover', function (d) {
            var tclass = $(this).attr('class');
            $(this).attr('class', tclass+' hover');
          });
          histogram_now_rect.on('mouseleave', function (d) {
            var tclass = $(this).attr('class').split(' '),
              result = '';
            for (var i in tclass) {
              if (tclass[i] === 'hover') continue;
              else {
                result = result + tclass[i] + ' ';
              }
            }
            $(this).attr('class', result.slice(0, result.length-1));
          });
          redraw('histogramLegend');
        });
    return;
  }

  if (f==='histogramView') {
    if (arg===histogram_view_var) return;
    histogram_view_var = arg;
    if (arg ==='Grouped') {
      histogram_y_scale.domain([0, histogramYGroupMax*1.1]);
      histogram_now_rect
        .transition()
          .duration(500)
          .delay(function (d, i) { return i * 20; })
          .attr("x", function (d, i, j) {
            return histogram_x_scale(d.x) +
              histogram_x_scale.rangeBand() /
              content[histogram_stack_var].length * j;
          })
          .attr("width", histogram_x_scale.rangeBand() /
            content[histogram_stack_var].length)
        .transition()
          .attr("y", function (d) { return histogram_y_scale(d.y); })
          .attr("height", function (d) {
            return chart_height - histogram_y_scale(d.y);
          });
    }
    else {
      histogram_y_scale.domain([0, histogramYStackMax*1.1]);
      histogram_now_rect
        .transition()
          .duration(500)
          .delay(function (d, i) { return i * 20; })
          .attr("y", function (d) { return histogram_y_scale(d.y0 + d.y); })
          .attr("height", function (d) {
            return histogram_y_scale(d.y0) - histogram_y_scale(d.y0 + d.y);
          })
        .transition()
          .attr("x", function(d) { return histogram_x_scale(d.x); })
          .attr("width", histogram_x_scale.rangeBand());
    }
    $('.bar .y.axis').remove();
    histogram.append("g")
        .attr("class", "y axis")
        .call(histogram_yAxis)
      .append("text")
        .attr("class", "label")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr('x', -10)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text(histogram_y_var);
    return;
  }

// map color adjustment
  if (f === 'landingColor') {
    var legend;

    if (arg === landing_color_var) return;
    landing_color_var = arg;
    landing_map_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .style('fill', function (d) {
        if (!d.active) return color_pattern(d[landing_color_var]);
      });
    $('.landing .legend').remove();
    legend = landing_map.append("g")
      .attr("class", "legend");
    redraw('landingLegend');
    return;
  }

  if (f === 'departureColor') {
    var legend;

    if (arg === departure_color_var) return;
    departure_color_var = arg;
    departure_map_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .style('fill', function (d) {
        if (!d.active) return color_pattern(d[departure_color_var]);
      });
    $('.departure .legend').remove();
    legend = departure_map.append("g")
      .attr("class", "legend");
    redraw('departureLegend');
    return;
  }

// map size adjustment
  if (f === 'landingSize') {
    if (landing_size_var === arg) return;
    landing_size_var = arg;
    landing_map_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .attr('r', function (d) {
        if (landing_size_var) {
          if (!d.active) {
            return landing_size_scale(d[landing_size_var]);
          }
          else return 4+landing_size_scale(d[landing_size_var]);
        }
        if (!d.active) return 2.5;
        else return 6.5;
      });
    return;
  }

  if (f === 'departureSize') {
    if (departure_size_var === arg) return;
    departure_size_var = arg;
    departure_map_now
      .transition()
      .duration(500)
      .delay( function (d, i) {
        return 500+1*i;
      })
      .attr('r', function (d) {
        if (departure_size_var) {
          if (!d.active) {
            return departure_size_scale(d[departure_size_var]);
          }
          else return 4+departure_size_scale(d[departure_size_var]);
        }
        if (!d.active) return 2.5;
        else return 6.5;
      });
    return;
  }
}

/**
 * Reselect the data
 */
function filterfunc() {
  var flag = true;
  cur_dataset = [];
  departure_dataset = [];
  for (var i in global_geo_dataset) {
    flag = true;
    for (var j in filter) {
      if (filter[j] !== null && filter[j] !== global_geo_dataset[i][j]) {
        flag = false;
        break;
      }
    }
    if (flag) {
      cur_dataset.push(global_geo_dataset[i]);
      if (global_geo_dataset[i].d_lo !== 0.0) {
        departure_dataset.push(global_geo_dataset[i]);
      }
    }
  }
}

/**
 * Check if the data is loaded and go on
 */
function main() {
  if (!passenger_data_flag||!geo_data_flag) {
    setTimeout(main, 1000);
    return;
  }

  redraw('nofilter');

// input interaction
  $('.input').on('keyup', function (d) {
    var input_value = $('input').val(),
      to_append = '';
    $('#searchHelper').empty();
    if (input_value === '') {
      $('#searchHelper').addClass('hidden');
      return;
    }
    $('#searchHelper').removeClass('hidden');
    to_append = '<ul>';
    for (var t in passenger_map) {
      if (t.length >= input_value.length &&
        t.slice(0, input_value.length) === input_value ||
        t.split(' ')[1].slice(0, input_value.length) === input_value) {
        to_append = to_append + '<li>'+t+'</li>';
        if (t.length === input_value.length) {
          $('#searchHelper').addClass('hidden');
          return;
        }
      }
    }
    $('#searchHelper').append(to_append + '</ul>');
  });
  $('.input').on('change', function (d) {
    $('line.target').remove();
    var input_value = $('input').val(),
      target_id = passenger_map[input_value],
      t_x,
      t_y;
    if (target_id === undefined) return;

    t_x = $('circle[index='+target_id+']')
      .map( function (d,e) { return $(e).attr('cx'); } );
    t_y = $('circle[index='+target_id+']')
      .map( function (d,e) { return $(e).attr('cy'); } );
    d3.select('g.landing')
      .insert('line')
        .attr('class', 'target y')
        .attr('x1', 0)
        .attr('y1', t_y[0])
        .attr('x2', map_width)
        .attr('y2', t_y[0])
        .attr('index', target_id);
    d3.select('g.landing')
      .insert('line')
        .attr('class', 'target x')
        .attr('x1', t_x[0])
        .attr('y1', 0)
        .attr('x2', t_x[0])
        .attr('y2', map_height)
        .attr('index', target_id);
    if (t_x.length === 3) {
      d3.select('g.departure')
        .insert('line')
          .attr('class', 'target y')
          .attr('x1', 0)
          .attr('y1', t_y[1])
          .attr('x2', map_width)
          .attr('y2', t_y[1])
          .attr('index', target_id);
      d3.select('g.departure')
        .insert('line')
          .attr('class', 'target x')
          .attr('x1', t_x[1])
          .attr('y1', 0)
          .attr('x2', t_x[1])
          .attr('y2', map_height)
          .attr('index', target_id);
      d3.select('g.scatter')
        .insert('line')
          .attr('class', 'target y')
          .attr('x1', 0)
          .attr('y1', t_y[2])
          .attr('x2', chart_width)
          .attr('y2', t_y[2])
          .attr('index', target_id);
      d3.select('g.scatter')
        .insert('line')
          .attr('class', 'target x')
          .attr('x1', t_x[2])
          .attr('y1', 0)
          .attr('x2', t_x[2])
          .attr('y2', chart_height)
          .attr('index', target_id);
    }
    else {
      d3.select('g.scatter')
        .insert('line')
          .attr('class', 'target y')
          .attr('x1', 0)
          .attr('y1', t_y[1])
          .attr('x2', chart_width)
          .attr('y2', t_y[1])
          .attr('index', target_id);
      d3.select('g.scatter')
        .insert('line')
          .attr('class', 'target x')
          .attr('x1', t_x[1])
          .attr('y1', 0)
          .attr('x2', t_x[1])
          .attr('y2', chart_height)
          .attr('index', target_id);
    }
  });
// close the modal when the data is ready
  $('.basic.modal')
    .modal('hide');
}

read_data();
main();