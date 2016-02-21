$(function(){
  "use strict";
  var globals = {
    firstClick: true,
    gameover: false,
    canvas: null,
    context: null,
    totalMines: 0,
    totalFlags: 0,
    elapsedTime: 0,
    clock: '',
    restart: '',
    mineMap: '',
    flagMap: '',
    revealedMap: '',
    currentAnimation: '',
    previous: new Array(2),
    squaresX: '',
    squaresY: ''
  },

  defaults = {
    difficulty: 0,
    celSize: 20,
    width: 600,
    height: 400,
    background: 'white',
    font: '14px Arial',
    celColor: '#dadada',
    celStroke: 'white',
    celRadius: 5,
    mineImg: 'images/mine.png',
    flagImg: 'images/flag.png'
  },

  containers = {

  };
  var core = {
    init: function(){
      globals.canvas = $('#board');
      globals.context = globals.canvas[0].getContext("2d");
      globals.context.background = defaults.background;

      var ratio = this.hiDPIRatio();
      if (ratio !== 1) {
        var originalWidth = globals.canvas[0].width;
        var originalHeight = globals.canvas[0].height;

        globals.canvas[0].width = originalWidth * ratio;
        globals.canvas[0].height = originalHeight * ratio;
        globals.canvas.css({
          width: originalWidth + "px",
          height: originalHeight + "px"
        });

        globals.context.scale(ratio, ratio);
      }

      globals.context.font = defaults.font;

      defaults.width = globals.canvas.width();
      globals.squaresX = Math.floor(defaults.width / defaults.celSize);
      globals.squaresY = Math.floor(defaults.height / defaults.celSize);

      globals.mineMap = new Array(globals.squaresX);
      globals.flagMap = new Array(globals.squaresX);
      globals.revealedMap = new Array(globals.squaresX);

      containers.flags = $('#flags');
      containers.mines = $('#mines');
      containers.status = $('#status');
      containers.time = $('#time');
      containers.msg = $('#msg');
      containers.scoreboard = $('#scoreboard');

      containers.easy = $('#easybtn');
      containers.medium = $('#mediumbtn');
      containers.insane = $('#insanebtn');
      containers.switchscreens = $('#switchscreens');
      containers.reset = $('#reset');
      containers.save = $('#save');
      containers.load = $('#load');
      containers.upload = $('#upload');

      var difarr = { 9: containers.easy, 6: containers.medium, 3: containers.insane};

      $.each(difarr, function(index, value){
        value.on({
          click: function(){
            defaults.difficulty = index;
            util.switchScreens();
          }
        });
      });

      containers.switchscreens.on({
        click: function(){
          util.switchScreens();
        }
      });

      containers.reset.on({
        click: function(){
          core.reset();
        }
      });

      containers.save.on({
        click: function() {
          if (defaults.difficulty == 0) {
            alert('Game not started yet!');
          }
          else if (globals.gameover) {
            alert('Game Over!');
          }
          else util.save();
        }
      });

      containers.load.on({
        click: function() {
          containers.upload.click();
        }
      });

      containers.upload.on({
        click: function(evt) {
          this.value = null;
        },
        change: function(evt) {
          util.load(evt);
        }
      });
      $('.gamescreen').hide();

      globals.canvas.on({
        mouseup: function(e){
          action.click(e);
        },
        mousemove: function(e){
          action.hover(e);
        }
      });

      var images = new Array();
      images[0] = new Image();
      images[0].src = defaults.mineImg;
      images[1] = new Image();
      images[1].src = defaults.flagImg;

      core.setup();

    },

    hiDPIRatio: function() {
      var devicePixelRatio, backingStoreRatio;

      devicePixelRatio = window.devicePixelRatio || 1;
      backingStoreRatio = globals.context.webkitBackingStorePixelRatio ||
      globals.context.mozBackingStorePixelRatio ||
      globals.context.msBackingStorePixelRatio ||
      globals.context.oBackingStorePixelRatio ||
      globals.context.backingStorePixelRatio || 1;

      return devicePixelRatio / backingStoreRatio;
    },
    reset: function(){
      window.clearInterval(globals.clock);
      window.clearInterval(globals.restart);

      globals.context.clearRect(0,0,defaults.width,defaults.height);

      globals.gameover = false;
      globals.firstClick = true;
      globals.totalMines = 0;
      globals.totalFlags = 0;
      globals.elapsedTime = 0;
      globals.mineMap = new Array(globals.squaresX);
      globals.flagMap = new Array(globals.squaresX);
      globals.revealedMap = new Array(globals.squaresX);

      containers.flags.html('');
      containers.mines.html('');
      containers.status.html('Game on :)');
      containers.time.html('0');
      containers.msg.html('Click on a square to start the game!');

      core.setup();

      window.clearInterval(globals.currentAnimation);
      animation.walker();
    },
    setup: function(){

      for(var k = 0; k < globals.squaresX; k++){
        globals.flagMap[k] = Array(globals.squaresY);
        globals.revealedMap[k] = Array(globals.squaresY);
      }

      globals.context.strokeStyle = defaults.celStroke;
      globals.context.fillStyle = defaults.celColor;

      animation.standardBoard();
    },

    timer: function(){
      globals.clock = setInterval(function(){
        globals.elapsedTime++;

        containers.time.html(globals.elapsedTime);
      }, 1000);
    }
  };

  var action = {
    click: function(e){
      if(globals.gameover){
        return false;
      }

      var x, y, l;
      x = Math.floor((e.pageX - globals.canvas[0].offsetLeft - 1) / defaults.celSize);
      y = Math.floor((e.pageY - globals.canvas[0].offsetTop - 1) / defaults.celSize);
      l = (globals.revealedMap[x][y]) ? 1 : -1;

      if(e.which === 1 && globals.flagMap[x][y] !== 1 && defaults.difficulty !== 0){

      if(globals.firstClick === true){

        window.clearInterval(globals.currentAnimation);
        animation.standardBoard();

        core.timer();

        do{
          action.generateMines(globals.mineMap);
        }while(globals.mineMap[x][y] === -1);

        containers.mines.html('You have to find ' + globals.totalMines + ' mines to win.');
        globals.firstClick = false;
      }

      action.index(x, y);

    }else if(e.which === 3 && util.is('revealed', x, y)){

     var num = 0,
     surrounded = new Array(),
     xArr = [x, x + 1, x - 1],
     yArr = [y, y + 1, y - 1];

     for(var a = 0; a < 3; a++){
      for(var b = 0; b < 3; b++){

       if(util.is('flag', xArr[a], yArr[b])){
         num++;
       }else{
         surrounded.push([xArr[a], yArr[b]]);
       }
     }
   }

   if(num === globals.mineMap[x][y]){
    $.each(surrounded, function(){

     action.index(this[0], this[1]);
   });
  }

}else if(e.which === 3 && l < 0 && globals.firstClick !== true){

  var flag = new Image();
  flag.src = defaults.flagImg;
  flag.onload = function(){
    action.flag(flag,x,y);
  };
}
},

hover: function(e){

  if(!globals.gameover){

   var x = Math.floor((e.pageX - globals.canvas[0].offsetLeft - 1) / defaults.celSize),
   y = Math.floor((e.pageY - globals.canvas[0].offsetTop - 1) / defaults.celSize),
   l = (globals.revealedMap[x][y]) ? 1 : -1,
   f = (globals.flagMap[x][y]) ? 1 : -1;

   var pX = globals.previous[0],
   pY = globals.previous[1];

   if(typeof pX !== 'undefined' && globals.revealedMap[pX][pY] !== 1 && globals.flagMap[pX][pY] !== 1){
    globals.context.fillStyle = defaults.celColor;
    util.roundRect(globals.previous[0], globals.previous[1]);
  }

  if(l < 0 && f < 0 && !globals.firstClick){

    globals.context.fillStyle = '#aaa';
    util.roundRect(x, y);
    globals.previous[0] = x;
    globals.previous[1] = y;
  }
}
},

index: function(x, y){

  if(x >= 0 && y >= 0 && x <= globals.squaresX && y <= globals.squaresY && globals.mineMap[x] !== undefined){

    var l = (globals.revealedMap[x][y]) ? 1 : -1;

    if(!util.is('revealed', x, y)){

      globals.revealedMap[x][y] = 1;

      if(globals.mineMap[x][y] !== -1){

       var alpha = 0.1,
       squareFade = setInterval(function(){
        globals.context.strokeStyle = 'white';
        globals.context.fillStyle = 'rgba(255,255,255,' + alpha + ')';
        util.roundRect(x, y);

        if(globals.mineMap[x][y] !== -1){

         var colorMap = ['none', 'blue', 'green', 'red',  'black', 'orange', 'cyan'];
         globals.context.fillStyle = colorMap[globals.mineMap[x][y]];
         globals.context.fillText(globals.mineMap[x][y], (x * defaults.celSize) + 5, (y * defaults.celSize) + 16);
       }

       alpha = alpha + .1;

       if(alpha > 1){
         window.clearInterval(squareFade);
       }
     }, 50);

     }else{

      var mine = new Image();
      mine.src = defaults.mineImg;
      mine.onload = function() {
        action.revealMines(mine);
      };
    }

    if(globals.mineMap[x][y] === 0){

      for(var i = -1; i <= 1; i++){
        for(var j = -1; j <= 1; j++){

          if(l < 0 && x + i >= 0 && y + j >= 0 && x + i <= globals.squaresX && y + j <= globals.squaresX){
            action.index(x + i, y + j);
          }
        }
      }
    }
  }
}
},

flag: function(flag, x, y){

  if(globals.flagMap[x][y] !== 1){

    globals.context.drawImage(flag, x * defaults.celSize, y * defaults.celSize, defaults.celSize, defaults.celSize);
    globals.flagMap[x][y] = 1;
    globals.totalFlags++;

  }else{

    var img = globals.context.createImageData(defaults.celSize, defaults.celSize);
    for(var i = img.data.length; --i >= 0;){
      img.data[i] = 0;
    }

    globals.context.putImageData(img, x * defaults.celSize, y * defaults.celSize);

    globals.context.strokeStyle = defaults.celStroke;
    globals.context.fillStyle = defaults.celColor;

    util.roundRect(x, y);

    globals.flagMap[x][y] = 0;
    globals.totalFlags--;
  }

  containers.mines.html('You have to find ' + (globals.totalMines - globals.totalFlags) + ' mines to win.');
  containers.flags.html('You have set ' + globals.totalFlags + ' flags.');

  action.won();
},
won: function(){

  var count = 0;

  for(var i = 0; i < globals.squaresX; i++){
    for(var j = 0; j < globals.squaresY; j++){
      if((globals.flagMap[i][j] === 1 ) && (globals.mineMap[i][j] === -1)){
        count++;
      }
    }
  }

  if(count === globals.totalMines){

    globals.gameover = true;
    containers.status.html('You won! :D');

    window.clearInterval(globals.clock);
  }
},
generateMines: function(){

  for(var i = 0; i < globals.squaresX; i++){
    globals.mineMap[i] = new Array(globals.squaresX);

    for(var j = 0; j < globals.squaresY; j++){
      globals.mineMap[i][j] = Math.floor((Math.random() * defaults.difficulty) - 1);

      if(globals.mineMap[i][j] > 0){
        globals.mineMap[i][j] = 0;
      }
    }
  }

  action.calculateMines();
},
calculateMines: function() {

  var mineCount = 0;
  globals.totalMines = 0;

  for(var i = 0; i < globals.squaresX; i++){
    for(var j = 0; j < globals.squaresY; j++){

     if(globals.mineMap[i][j] === -1){

      var xArr = [i, i + 1, i - 1],
      yArr = [j, j + 1, j - 1];
      for(var a = 0; a < 3; a++){
        for(var b = 0; b < 3; b++){
         if(util.is('mine', xArr[a], yArr[b])){
          globals.mineMap[xArr[a]][yArr[b]]++;
        }
      }
    }

    globals.totalMines++;
  }
}
}
},
revealMines: function(mine){

  for(var i = 0; i < globals.squaresX; i++){
    for(var j = 0; j < globals.squaresY; j++){
      if(globals.mineMap[i][j] === -1){
        globals.context.drawImage(mine, i * defaults.celSize, j * defaults.celSize, defaults.celSize, defaults.celSize);
      }
    }
  }

  globals.gameover = true;
  containers.status.html('Game over :(');
    containers.msg.html('Click the reset button to start a new game');

    window.clearInterval(globals.clock);
  }
};

var animation = {

  standardBoard: function(){

    globals.context.fillStyle = defaults.celColor;

    for(var i = 0; i <= globals.squaresX; i++){
      for(var j = 0; j <= globals.squaresY; j++){
        util.roundRect(i, j);
      }
    }
  },

  walker: function(){
    globals.context.strokeStyle = defaults.celStroke;
    var droplet = [],
    speed = [],
    length = [];
    for (var i = 0; i < globals.squaresX; ++i) {
      droplet[i] = ~~(Math.random()*globals.squaresX);
      speed[i] = ~~(Math.random()*2)+1;
      length[i] = ~~(Math.random()*(globals.squaresY/2-3))+3;
    }

    globals.currentAnimation = setInterval(function(){

      animation.standardBoard();

      for (var i = 0; i < globals.squaresX; ++i) {
        for (var j = 0; j < length[i]; ++j) {
          globals.context.fillStyle = 'rgba(66,139,202, '+ 0.8*Math.pow(0.8, j+2)+')';
          util.roundRect(i, (droplet[i]-j+globals.squaresY)%globals.squaresY);
        }
      }

      for (var i = 0; i < globals.squaresX; ++i) {
        droplet[i] += speed[i];
        droplet[i] %= globals.squaresY;
      }
    }, 80);
  }
};

var util = {

  roundRect: function(x, y){

    var width = defaults.celSize - 1,
    height = defaults.celSize - 1,
    x = x * defaults.celSize,
    y = y * defaults.celSize;

    globals.context.beginPath();
    globals.context.moveTo(x + defaults.celRadius, y);
    globals.context.lineTo(x + width - defaults.celRadius, y);
    globals.context.quadraticCurveTo(x + width, y, x + width, y + defaults.celRadius);
    globals.context.lineTo(x + width, y + height - defaults.celRadius);
    globals.context.quadraticCurveTo(x + width, y + height, x + width - defaults.celRadius, y + height);
    globals.context.lineTo(x + defaults.celRadius, y + height);
    globals.context.quadraticCurveTo(x, y + height, x, y + height - defaults.celRadius);
    globals.context.lineTo(x, y + defaults.celRadius);
    globals.context.quadraticCurveTo(x, y, x + defaults.celRadius, y);
    globals.context.closePath();
    globals.context.stroke();
    globals.context.fill();
  },
  switchScreens: function(){
    if($('.startscreen').is(':hidden') === false){
      $('.startscreen').fadeToggle(400, 'swing', function(){
        core.reset();
        $('.gamescreen').fadeToggle();
      });
    }else{
      $('.gamescreen').fadeToggle(400, 'swing', function(){
        core.reset();
        defaults.difficulty = 0;
        $('.startscreen').fadeToggle();
      });
    }
  },

  is: function(what, x, y){
    var p = {
     'revealed': globals.revealedMap,
     'mine': globals.mineMap,
     'flag': globals.flagMap
   };

   if(typeof p[what][x] !== 'undefined' && typeof p[what][x][y] !== 'undefined' && p[what][x][y] > -1){
     return true;
   }else{
     return false;
   }
 },

  save: function(){
    var json = JSON.stringify({
      // globals
      elapsedTime: globals.elapsedTime,
      firstClick: globals.firstClick,
      flagMap: globals.flagMap,
      mineMap: globals.mineMap,
      revealedMap: globals.revealedMap,
      totalFlags: globals.totalFlags,
      totalMines: globals.totalMines,
      // defaults
      difficulty: defaults.difficulty
    });
    var blob = new Blob([json], {type: "application/json"});
    saveAs(blob, "save.txt");
  },

  load: function(evt) {
    var file = evt.originalEvent.target.files[0],
        reader = new FileReader(),
        obj;
    reader.onerror = util.loaderror;
    reader.onload = function(evt) {
      if (evt.target.readyState == FileReader.DONE) {
        var json = evt.target.result;
        obj = JSON && JSON.parse(json) || $.parseJSON(json);
        util.reload(obj);
      };
    };
    reader.readAsText(file);
  },

  loaderror: function(evt) {
    switch(evt.target.error.code) {
      case evt.target.error.NOT_FOUND_ERR:
        alert('File Not Found!');
        break;
      case evt.target.error.NOT_READABLE_ERR:
        alert('File is not readable');
        break;
      case evt.target.error.ABORT_ERR:
        break; // noop
      default:
        alert('An error occurred reading this file.');
    };
  },

  reload: function(obj) {
      core.reset();
      if($('.startscreen').is(':hidden') === false){
        $('.startscreen').fadeToggle(400, 'swing', function(){
          $('.gamescreen').fadeToggle();
        });
      }
      defaults.difficulty = obj.difficulty;
      if (obj.firstClick) return;
      globals.firstClick = obj.firstClick;
      globals.elapsedTime = obj.elapsedTime;
      globals.mineMap = obj.mineMap;
      globals.totalFlags = obj.totalFlags;
      globals.totalMines = obj.totalMines;

      window.clearInterval(globals.currentAnimation);
      animation.standardBoard();

      core.timer();
      containers.mines.html('You have to find ' + globals.totalMines + ' mines to win.');

      util.reclick(obj);
      util.reflag(obj);
  },

  reclick: function(obj) {
    for(var k = 0; k < globals.squaresX; ++k){
      for(var m = 0; m < globals.squaresY; ++m){
        if (obj.revealedMap[k][m] == 1) {
          action.index(k, m);
        }
      }
    }
  },

  reflag: function(obj) {
    var flag = new Image();
    flag.src = defaults.flagImg;
    flag.onload = function(){
      for(var k = 0; k < globals.squaresX; ++k){
        for(var m = 0; m < globals.squaresY; ++m){
          if (obj.flagMap[k][m] == 1) {
            action.flag(flag, k, m);
          }
        }
      }
    };
  }
};
core.init();
});