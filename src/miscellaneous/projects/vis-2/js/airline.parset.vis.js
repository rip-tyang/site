var source_dimension = ["source cont.","source country","source city"],
  destination_dimension = ["dest. cont.","dest. country","dest. city"],
  gmask = 0,
  scondition = {
    "condition": "normal",
    "dimension": 0,
    "selected": []
  },
  dcondition = {
    "condition": "normal",
    "dimension": 0,
    "selected": []
  },
  acondition = {
    "condition": "normal",
    "active": "Y"
  },
  chart = d3.parsets().dimensions([
    source_dimension[scondition["dimension"]],
    "active",
    destination_dimension[dcondition["dimension"]]
  ]).height(400),
  filterfunc = function(mask, d){
    if((mask & 0x1) && d["source cont."] == d["dest. cont."]) return null;
    if((mask & 0x2) && d["source country"] == d["dest. country"]) return null;
    return d;
  },
  selectfunc = function(scondition, dcondition, acondition, d){
    if(!d) return null;
    if(scondition["selected"][0] &&
      d[source_dimension[scondition["selected"].length-1]] != scondition["selected"][0])
      return null;
    if(dcondition["selected"][0] &&
      d[destination_dimension[dcondition["selected"].length-1]] != dcondition["selected"][0])
      return null;
    if(acondition["condition"] == "selected" &&
      d["active"] != acondition["active"])
      return null;
    return d;
  };

var vis = d3.select("#vis").append("svg")
    .attr("width", chart.width())
    .attr("height", chart.height());

function curves() {
  var t = vis.transition().duration(1000);
  t.call(chart.tension(this.checked ? .5 : 1));
}

function filter(mask) {
  if(this.checked == true)
    gmask |= mask;
  else
    gmask &= ~mask;
  load(false);
  //confime the curves
  curves.call($("input#curved")[0]);
}

function zoom_in_handler() {
  if( 0 === $("sp.camp").text().search(/source/) ) {
    if(scondition["dimension"]<2) {
      ++scondition["dimension"];
      if("normal" == scondition["condition"])
        scondition["selected"].unshift($("sp.name").text());
      else
        scondition["condition"] = "normal";
      load(true);
      //confime the curves
      curves.call($("input#curved")[0]);
    }
  }
  else if( 0 === $("sp.camp").text().search(/dest./) ) {
    if(dcondition["dimension"]<2) {
      ++dcondition["dimension"];
      if("normal" == dcondition["condition"])
        dcondition["selected"].unshift($("sp.name").text());
      else
        dcondition["condition"] = "normal";
      load(true);
      //confime the curves
      curves.call($("input#curved")[0]);
    }
  }
  $.unblockUI();
}

function select_handler() {
  if( 0 === $("sp.camp").text().search(/source/) ) {
    if("normal" == scondition["condition"]) {
      scondition["condition"] = "selected";
      scondition["selected"].unshift($("sp.name").text());
    }
    else return null;
  }
  else if( 0 === $("sp.camp").text().search(/dest./) ) {
    if("normal" == dcondition["condition"]) {
      dcondition["condition"] = "selected";
      dcondition["selected"].unshift($("sp.name").text());
    }
    else return null;
  }
  else {
    if("normal" == acondition["condition"]) {
      acondition["active"] = $("sp.name").text();
      acondition["condition"] = "selected";
    }
    else return null;
  }
  load(true);
  //confime the curves
  curves.call($("input#curved")[0]);
  $.unblockUI();
}

function load(r) {
  if(r) chart = d3.parsets().dimensions(now_dimension()).height(400);
  d3.csv("output.csv", function(d) {
      return selectfunc(scondition, dcondition, acondition, filterfunc(gmask, d));
    },
    function(csv) {
      if(r) {
        $("#vis svg").remove();
        vis = d3.select("#vis").append("svg")
          .attr("width", chart.width())
          .attr("height", chart.height());
      }
      vis.datum(csv).call(chart);
      $("tspan.zoom.out").off("click.parsets").on("click.parsets", function(){ zoom_out_handler( $($(this).siblings()[0]).text() );} );
      load_barchart_data();
  });
}

function zoom_out_handler(flag){
  if(0 == flag.search(/dest./)) {
    if(dcondition["condition"] == "normal" && dcondition["dimension"] > 0) {
      --dcondition["dimension"];
      dcondition["selected"].shift();
    }
    else if(dcondition["condition"] == "selected") {
      dcondition["selected"].shift();
      dcondition["condition"] = "normal";
    }
    else return null;
  }
  if(0 == flag.search(/source/)) {
    if(scondition["condition"] == "normal" && scondition["dimension"] > 0) {
      --scondition["dimension"];
      scondition["selected"].shift();
    }
    else if(scondition["condition"] == "selected") {
      scondition["selected"].shift();
      scondition["condition"] = "normal";
    }
    else return null;
  }
  if(0 == flag.search(/active/)) {
    if(acondition["condition"] == "selected") {
      acondition["condition"] = "normal";
    }
    else return null;
  }
  load(true);
  //confime the curves
  curves.call($("input#curved")[0]);
}

function now_dimension() {
  var tarray = $("#vis g.dimension").map(function(i,x){
    t = $(x).attr("transform");
    return Number(t.slice(t.indexOf(',')+1, t.indexOf(')')));
  }),
  tname = $("#vis g.dimension tspan.name").map(function(i,x){
    return $(x).text();
  }).map(function(i,x){
    if(0 == x.search(/source/)) return source_dimension[scondition["dimension"]];
    else if(0 == x.search(/dest./)) return destination_dimension[dcondition["dimension"]];
    else return "active";
  });
  tdimension = [
    {"index": tarray[0], "name": tname[0]},
    {"index": tarray[1], "name": tname[1]},
    {"index": tarray[2], "name": tname[2]}
  ].sort(function(n,m) {
    if(n["index"] < m["index"]) return -1;
    if(n["index"] == m["index"]) return 0;
    if(n["index"] > m["index"]) return 1;
  });
  return [
    tdimension[0]["name"],
    tdimension[1]["name"],
    tdimension[2]["name"]
  ];
}

load();