require 'coffee-script/register'
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
del = require 'del'
runSequence = require 'run-sequence'
webpack = require 'webpack'
WebpackDevServer = require("webpack-dev-server")
webpack_dev_config = require '../webpack.config'
webpack_runner = webpack webpack_dev_config

paths =
  src: 'src'
  dist: 'dist'

gulp.task 'webpack', () ->
  webpack_runner.run (err, stats) ->
    throw new $.util.PluginError('webpack', err) if err
    $.util.log "[webpack]", stats.toString
      colors: true
      source: true
      timings: true

gulp.task 'jade', () ->
  gulp.src("#{paths.src}/jade/index.jade")
    .pipe $.plumber()
    .pipe $.jade
      data: "#{paths.src}/jade/data"
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
  new WebpackDevServer webpack_runner,
    contentBase: paths.dist
    stats:
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false
  .listen 5000, 'localhost', (err) ->
    throw new $.util.PluginError('webpack-dev-server', err) if err

gulp.task 'dev:build', ['clean'], () ->
  runSequence ['jade', 'copy', 'webpack']

gulp.task 'dev:serve', ['clean'], () ->
  runSequence ['jade', 'copy', 'server']

gulp.task 'dev', ['dev:build']
