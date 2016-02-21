/**
 * global unchanged jQuery cache var
 */
var $descriptive = $('#descriptive');

/**
 * Block untile the data is loaded
 */

$('.basic.modal')
  .modal({ closable  : false, debug: false, verbose: false })
  .modal('show');

/**
 * Menu button interaction
 */
$('#sideswitch').on('mouseover', function (d) {
  $(this).addClass('longer');
});

$('#sideswitch').on('mouseleave', function (d) {
  $(this).removeClass('longer');
});

$('#sideswitch').on('click', function (d) {
  $('#menu').toggleClass('active');
  $('#sideswitch').toggleClass('pushed');
  $('.main.menu').toggleClass('pushed');
});

/**
 * Handle icon pop up
 */
$('.github.item').popup({
  debug: false,
  verbose: false,
  on: 'hover',
  variation: 'inverted',
  content: 'View source in Github'
});

$('.weibo.item').popup({
  debug: false,
  verbose: false,
  on: 'hover',
  variation: 'inverted',
  content: 'Share it to Weibo'
});

/**
 * Menu dropdown interaction
 */
$('.ui.dropdown.button').on('click', function (d) {
  $(this).dropdown('toggle');
  $(this).dropdown('hide others');
});

$('.filter.record').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Banned: 'Interdiction',
      Landed: 'Landing',
      Record: null
    };
    filter.record = map[$(this).find('div.text').text()];
    redraw();
  }
});

$('.filter.vessel').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = function (d) {
      if (d === 'Vessel') return null;
      return d;
    };
    filter.vessel = map($(this).find('div.text').text());
    redraw();
  }
});

$('.filter.year').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = function (d) {
      if (d === 'Year') return null;
      return +d;
    };
    filter.year = map($(this).find('div.text').text());
    redraw();
  }
});

$('.filter.day').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = function (d) {
      if (d === 'Day') return null;
      return +d;
    };
    filter.day = map($(this).find('div.text').text());
    redraw();
  }
});

$('.filter.month').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Month: null,
      January: 1,
      February: 2,
      March: 3,
      April: 4,
      May: 5,
      June: 6,
      July: 7,
      August: 8,
      September: 9,
      October: 10,
      November: 11,
      December: 12
    };
    filter.month = map[$(this).find('div.text').text()];
    redraw();
  }
});

$('.filter.week').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Week: null,
      Monday: 0,
      Tuesday: 1,
      Wednesday: 2,
      Thursday: 3,
      Friday: 4,
      Saturday: 5,
      Sunday: 6
    };
    filter.week = map[$(this).find('div.text').text()];
    redraw();
  }
});

$('.landing.color').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Record: 'record',
      Vessel: 'vessel'
    };
    redraw('landingColor', map[$(this).find('div.text').text()]);
  }
});

$('.landing.size').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Size: null,
      Persons: 'persons',
      Deaths: 'deaths',
      'Death Rate': 'rate'
    },
    arg = map[$(this).find('div.text').text()];
    if(arg) {
      landing_size_scale.domain(d3.extent(cur_dataset, function(d) {
        return d[arg];
      }));
    }
    redraw('landingSize', arg);
  }
});

$('.departure.color').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Record: 'record',
      Vessel: 'vessel'
    };
    redraw('departureColor', map[$(this).find('div.text').text()]);
  }
});

$('.departure.size').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Size: null,
      Persons: 'persons',
      Deaths: 'deaths',
      'Death Rate': 'rate'
    },
    arg = map[$(this).find('div.text').text()];
    if(arg) {
      departure_size_scale.domain(d3.extent(cur_dataset, function(d) {
        return d[arg];
      }));
    }
    redraw('departureSize', arg);
  }
});

$('.histogram.xControl').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Month: 'month',
      Week: 'week',
      Year: 'year'
    };
    redraw('histogramXControl', map[$(this).find('div.text').text()]);
  }
});

$('.histogram.yControl').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Persons: 'persons',
      Deaths: 'deaths',
      'Death Rate': 'rate',
      Ships: 'ships'
    };
    if (histogram_stack_var === 'vessel') {
      redraw('histogramYControl', map[$(this).find('div.text').text()]);
    }
    else if (histogram_stack_var === 'death') {
      $(this).find('div.text').text('Deaths');
    }
    else {
      $(this).find('div.text').text('Ships');
    }
  }
});

$('.histogram.stack').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Vessel: 'vessel',
      Record: 'record',
      Death: 'death'
    };
    redraw('histogramStack', map[$(this).find('div.text').text()]);
  }
});

$('.histogram.view').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    redraw('histogramView', $(this).find('div.text').text());
  }
});

$('.scatter.xControl').dropdown({
  debug: false,
  verbose: false
});

$('.scatter.yControl').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Persons: 'persons',
      Deaths: 'deaths',
      'Death Rate': 'rate'
    };
    redraw('scatterYControl', map[$(this).find('div.text').text()]);
  }
});

$('.scatter.color').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Record: 'record',
      Vessel: 'vessel'
    };
    redraw('scatterColor', map[$(this).find('div.text').text()]);
  }
});

$('.scatter.size').dropdown({
  debug: false,
  verbose: false,
  onChange: function (d) {
    var map = {
      Size: null,
      Persons: 'persons',
      Deaths: 'deaths',
      'Death Rate': 'rate'
    };
    var arg = map[$(this).find('div.text').text()];
    if(arg) {
      scatter_size_scale.domain(d3.extent(cur_dataset, function(d) {
        return d[arg];
      }));
    }
    redraw('scatterSize', arg);
  }
});

// navigator interaction
$('.navi.dropdown').dropdown({
  debug: false,
  verbose: false,
  on: 'hover',
});