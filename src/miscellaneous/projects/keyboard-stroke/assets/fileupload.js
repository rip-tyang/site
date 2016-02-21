var chMap,
    keyValue,
    NumberAndPunctuation = {
      '`': 192,
      '~': 192,
      '1': 49,
      '!': 49,
      '2': 50,
      '@': 50,
      '3': 51,
      '#': 51,
      '4': 52,
      '$': 52,
      '5': 53,
      '%': 53,
      '6': 54,
      '^': 54,
      '7': 55,
      '&': 55,
      '8': 56,
      '*': 56,
      '9': 57,
      '(': 57,
      '0': 48,
      ')': 48,
      '-': 189,
      '_': 189,
      '=': 187,
      '+': 187,
      '[': 219,
      '【': 219,
      '{': 219,
      ']': 221,
      '】': 221,
      '}': 221,
      '|': 220,
      '\\': 220,
      ';': 186,
      ':': 186,
      '"': 222,
      '“': 222,
      '”': 222,
      '\'': 222,
      '‘': 222,
      '\n': 13,
      '<': 188,
      '《': 188,
      ',': 188,
      '，': 188,
      '>': 190,
      '》': 190,
      '.': 190,
      '。': 190,
      '/': 191,
      '?': 191
    },
    npValues = [192, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 189, 187, 219, 221, 220, 186, 222, 13, 188, 190, 191];

function fileUploadHandler(evt) {
  evt.stopPropagation();
  evt.preventDefault();
  reset();
  var fr = new FileReader();
  fr.onload = (function () {
    mapToKeyboard(this.result);
  });
  fr.readAsText(this.files[0]);
}

function mapToKeyboard(content) {
  keyValue = {};
  var l = content.length;
  for (var i = 0; i < l; ++i) {
    var code = content[i].charCodeAt();
    if (NumberAndPunctuation[content[i]]) {
      if (!keyValue[NumberAndPunctuation[content[i]]]) {
        keyValue[NumberAndPunctuation[content[i]]] = 0;
      }
      ++keyValue[NumberAndPunctuation[content[i]]];
    }
    else if (code < 127) {
      asciiToKeyboard(content[i]);
    }
    else if (chMap[content[i]]) {
      var pinyin = chMap[content[i]];
      pinyin.split('').forEach(function (l) {
        asciiToKeyboard(l);
      });
    }
  }
  showColors();
}

function asciiToKeyboard(code) {
  var code = code.charCodeAt();
  if (!keyValue[code]) keyValue[code] = 0;
  ++keyValue[code];
 }

function getChMap() {
  var r = new XMLHttpRequest();
  r.open("GET", "ch.txt", true);
  r.onreadystatechange = function () {
    if (r.readyState != 4 || r.status != 200) return;
    chMap = JSON.parse(r.responseText);
  };
  r.send();
}

function showColors() {
  var range = ['#ffffb2', '#fed976', '#feb24c', '#fd8d3c', '#fc4e2a', '#e31a1c', '#b10026'],
      targetKeyValue = [];
  for (var i = 65; i < 91; ++i) {
    targetKeyValue[i] = 0;
  }
  for (var i = 97; i < 123; ++i) {
    if (keyValue[i]) targetKeyValue[i-97+65] += keyValue[i];
    if (keyValue[i-97+65]) targetKeyValue[i-97+65] += keyValue[i-97+65];
  }
  for (var i in npValues) {
    if (keyValue[npValues[i]]) targetKeyValue[npValues[i]] = keyValue[npValues[i]];
  }
  var max = Number.MIN_VALUE, min = Number.MAX_VALUE;
  targetKeyValue.forEach( function (v) {
    if (v!=undefined) {
      max = max > v ? max : v;
      min = min < v ? min : v;
    }
  });

  var newValue = []
  for (var i = 65; i < 91; ++i) {
    newValue.push(targetKeyValue[i]);
    if (targetKeyValue[i] === 0) continue;
    var index = Math.floor((targetKeyValue[i] - min) / (max - min+1) * 7);
    var key = document.querySelector('.key.c' + i);
    key.style.background = range[index];
    key.title = targetKeyValue[i];
  }
  for (var i in npValues) {
    var v = targetKeyValue[npValues[i]];
    newValue.push(v);
    if (v === 0) continue;
    var index = Math.floor((v - min) / (max - min+1) * 7);
    var key = document.querySelector('.key.c' + npValues[i]);
    key.style.background = range[index];
    key.title = v;
  }
  myChart.setOption({
    series : [{data: newValue}]
  });
}

function reset() {
  var keys = document.querySelectorAll('.key');
  var l = keys.length;
  for (var i = 0; i < l; ++i) {
    keys[i].style.background = '#EFF0F2';
    keys[i].title = '';
  }
  myChart.setOption({
    series : [{data: empty}]
  });
}

window.onload = function() {
  getChMap();
  document.getElementById('fileUploadInput').onchange = fileUploadHandler;
}

