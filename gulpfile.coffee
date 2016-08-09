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


gulp.task 'jade', ->
  # uncache data.coffee from require cache
  delete require.cache[require.resolve("#{paths.src}/jade/data")]

  gulp.src("#{paths.src}/jade/index.jade")
    .pipe $.plumber()
    .pipe $.jade
      data: require("#{paths.src}/jade/data")
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

  gulp.watch ['src/jade/**/*'], ['jade', reload]
  gulp.watch ['src/jade/data.coffee'], ['jade', reload]
  gulp.watch ['src/assets/**/*'], ['copy:assets', reload]
  gulp.watch ['src/miscellaneous/**'], ['copy:miscellaneous', reload]

gulp.task 'build', ->
  runSequence 'clean', ['jade', 'copy', 'webpack']

gulp.task 'serve', ->
  runSequence 'clean', ['jade', 'copy', 'server']

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

gulp.task 'dist:jade', ->
  jade_data = require "#{paths.src}/jade/data"
  manifest_data = require "#{paths.dist}/manifest.json"

  jade_data.manifest = {}
  jade_data.manifest[key] = v for key, v of manifest_data

  gulp.src("#{paths.src}/jade/index.jade")
    .pipe $.plumber()
    .pipe $.jade
      data: jade_data
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
  runSequence 'test', 'clean', ['dist:webpack', 'dist:copy'], 'dist:jade'

gulp.task 'dist', ['dist:build']

gulp.task 'default', ['dist:build']
