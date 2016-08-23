require 'coffee-script/register'
fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
del = require 'del'
runSequence = require 'run-sequence'
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackConfig = require './webpack.config'
webpackStream = require 'webpack-stream'
http = require 'http'

paths =
  src: './src'
  dist: './dist'

entry = fs.readdirSync path.join(paths.src, 'coffee')
  .filter (e) -> /\.coffee$/.test e
  .filter (e) -> !(/^_/.test(e))
  .map (e) -> e[0..-8]

port = 5000
############################################
# dev
############################################


gulp.task 'pug', ->
  # uncache data.coffee from require cache
  delete require.cache[require.resolve("#{paths.src}/pug/data")]

  gulp.src("#{paths.src}/pug/[^_]*.pug")
    .pipe $.plumber()
    .pipe $.pug
      locals: require("#{paths.src}/pug/data")
      pretty: true
    .pipe gulp.dest(paths.dist)

gulp.task 'copy:assets', ->
  gulp.src("#{paths.src}/assets/**/*", { base: paths.src })
    .pipe gulp.dest(paths.dist)

gulp.task 'copy:miscellaneous', ->
  gulp.src("#{paths.src}/miscellaneous/**/*",
    { base: "#{paths.src}/miscellaneous" })
    .pipe gulp.dest(paths.dist)

gulp.task 'copy', ['copy:assets', 'copy:miscellaneous']

gulp.task 'clean', del.bind(null, [paths.dist])

gulp.task 'server', ->
  config =
    contentBase: paths.dist
    proxy: require './proxy'
    stats:
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false

  option =
    build: 'debug'
    port: port
    entry: entry

  webpack_dev_runner = webpack webpackConfig(option)
  wds = new WebpackDevServer(webpack_dev_runner, config)

  # reload browser when changes detected
  wds.app.get '/reload', (req, res) ->
    wds.sockWrite wds.sockets, 'ok'
    res.sendStatus 200
  wds.listen 5000, 'localhost', (err) ->
    throw new $.util.PluginError('webpack-dev-server', err) if err

  reload = ->
    http.get "http://localhost:#{port}/reload", ->
      $.util.log 'Reloading...'

  gulp.watch ['src/pug/**/*'], ['pug', reload]
  gulp.watch ['src/pug/data.coffee'], ['pug', reload]
  gulp.watch ['src/assets/**/*'], ['copy:assets', reload]
  gulp.watch ['src/miscellaneous/**'], ['copy:miscellaneous', reload]

gulp.task 'build', ->
  runSequence 'clean', ['pug', 'copy', 'webpack']

gulp.task 'serve', ->
  runSequence 'clean', ['pug', 'copy', 'server']

############################################
# test
############################################

gulp.task 'test', ->
  gulp.src('src/coffee/test/*', { read: false })
    .pipe $.mocha({ reporter: 'nyan' })


############################################
# dist
############################################

gulp.task 'dist:webpack', ->
  option =
    build: 'production'
    port: port
    entry: entry

  gulp.src "#{paths.src}/coffee/main.js"
    .pipe webpackStream(webpackConfig(option))
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:pug', ->
  pug_data = require "#{paths.src}/pug/data"
  manifest_data = require "#{paths.dist}/manifest.json"

  pug_data.manifest = {}
  pug_data.manifest[key] = v for key, v of manifest_data

  gulp.src("#{paths.src}/pug/[^_]*.pug")
    .pipe $.plumber()
    .pipe $.pug
      locals: pug_data
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy:assets', ->
  gulp.src("#{paths.src}/assets/**/*", { base: paths.src })
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy:miscellaneous', ->
  gulp.src("#{paths.src}/miscellaneous/**/*",
    { base: "#{paths.src}/miscellaneous" })
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy', ['dist:copy:assets', 'dist:copy:miscellaneous']

gulp.task 'dist:build', ->
  runSequence 'test', 'clean', ['dist:webpack', 'dist:copy'], 'dist:pug'

gulp.task 'dist', ['dist:build']

gulp.task 'default', ['dist:build']
