// navigator interaction
$('.navi.dropdown').dropdown({
  debug: false,
  verbose: false,
  on: 'hover',
});

$('.buttons a.button').on('mouseover', function (d) {
  $(this).css('color', '#D95C5C', 'very important');
});

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

$('.button.d3').popup({
  debug: false,
  verbose: false,
  position: 'right center',
  on: 'hover',
  variation: 'inverted',
  content: 'A javascript visualization library.'
});

$('.button.semantic').popup({
  debug: false,
  verbose: false,
  position: 'right center',
  on: 'hover',
  variation: 'inverted',
  content: 'A easy-to-use UI framework.'
});

$('.button.blog').popup({
  debug: false,
  verbose: false,
  position: 'right center',
  on: 'hover',
  variation: 'inverted',
  content: 'A shabby personal blog.'
});

$('#description').waypoint(function() {
  $('.peek .menu .item').removeClass('active');
  $('.description.item').addClass('active');
},{ offset: 150 });

$('#function').waypoint(function() {
  $('.peek .menu .item').removeClass('active');
  $('.function.item').addClass('active');
},{ offset: 150 });

$('#result').waypoint(function() {
  $('.peek .menu .item').removeClass('active');
  $('.result.item').addClass('active');
},{ offset: 150 });

$('.item.description').on('click', function (d) {
  $.scrollTo('#description', 500, { offset: -150 });
});

$('.item.function').on('click', function (d) {
  $.scrollTo('#function', 500, { offset: -150, onAfter: function (d) {
    $('.peek .menu .item').removeClass('active');
    $('.function.item').addClass('active');
  }});
});

$('.item.result').on('click', function (d) {
  $.scrollTo('#result', 500, { offset: -100 });
});