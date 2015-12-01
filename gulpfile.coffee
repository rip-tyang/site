require 'coffee-script/register'
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
del = require 'del'
runSequence = require 'run-sequence'
webpack = require 'webpack'
WebpackDevServer = require("webpack-dev-server")
webpack_dev_config = require './webpack.config'
webpack_dev_runner = webpack webpack_dev_config
webpack_dist_config = require './webpack.config.dist'
webpack_stream = require 'webpack-stream'

paths =
  src: './src'
  dist: './dist'

############################################
# dev
############################################


gulp.task 'webpack', () ->
  webpack_dev_runner.run (err, stats) ->
    throw new $.util.PluginError('webpack', err) if err
    $.util.log "[webpack]", stats.toString
      colors: true
      source: true
      timings: true

gulp.task 'jade', () ->
  gulp.src("#{paths.src}/jade/index.jade")
    .pipe $.plumber()
    .pipe $.jade
      data: require("#{paths.src}/jade/data")
      pretty: true
    .pipe gulp.dest(paths.dist)

gulp.task 'copy:assets', () ->
  gulp.src("#{paths.src}/assets/**/*", { base: paths.src })
    .pipe gulp.dest(paths.dist)

gulp.task 'copy:miscellaneous', () ->
  gulp.src("#{paths.src}/miscellaneous/**/*",
    {base: "#{paths.src}/miscellaneous"})
    .pipe gulp.dest(paths.dist)

gulp.task 'copy', ['copy:assets', 'copy:miscellaneous']

gulp.task 'clean', del.bind(null, [paths.dist])

gulp.task 'server', () ->
  new WebpackDevServer webpack_dev_runner,
    contentBase: paths.dist
    stats:
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false
  .listen 5000, 'localhost', (err) ->
    throw new $.util.PluginError('webpack-dev-server', err) if err

gulp.task 'build', () ->
  runSequence 'clean', ['jade', 'copy', 'webpack']

gulp.task 'serve', () ->
  runSequence 'clean', ['jade', 'copy', 'server']

############################################
# dist
############################################

gulp.task 'dist:webpack', () ->
  gulp.src "#{paths.src}/coffee/main.js"
    .pipe webpack_stream(webpack_dist_config)
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:jade', () ->
  jade_data = require "#{paths.src}/jade/data"
  manifest_data = require "#{paths.dist}/manifest.json"

  jade_data.manifest = {}
  jade_data.manifest[key] = v for key, v of manifest_data

  gulp.src("#{paths.src}/jade/index.jade")
    .pipe $.plumber()
    .pipe $.jade
      data: jade_data
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy:assets', () ->
  gulp.src("#{paths.src}/assets/**/*", { base: paths.src })
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy:miscellaneous', () ->
  gulp.src("#{paths.src}/miscellaneous/**/*",
    {base: "#{paths.src}/miscellaneous"})
    .pipe gulp.dest(paths.dist)

gulp.task 'dist:copy', ['dist:copy:assets', 'dist:copy:miscellaneous']

gulp.task 'dist:build', () ->
  runSequence 'clean', ['dist:webpack', 'dist:copy'], 'dist:jade'

gulp.task 'dist', ['dist:build']

gulp.task 'default', ['dist:build']
