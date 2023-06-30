require 'coffee-script/register'
fs = require 'fs'
path = require 'path'
gulp = require 'gulp'
$ = require('gulp-load-plugins')()
del = require 'del'
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackConfig = require './webpack.config'
http = require 'http'

paths =
  src: './src'
  dist: './dist'

entry = fs.readdirSync path.join(paths.src, 'coffee')
  .filter (e) -> /\.coffee$/.test e
  .filter (e) -> !(/^_/.test(e))
  .map (e) -> e[0..-8]

port = 5000

debug_option =
  build: 'debug'
  port: port
  entry: entry

prod_option =
  build: 'production'
  port: port
  entry: entry

############################################
# dev
############################################

exports.pug = task_pug = ->
  # uncache data.coffee from require cache
  delete require.cache[require.resolve("#{paths.src}/pug/data")]

  gulp.src "#{paths.src}/pug/[^_]*.pug"
    .pipe $.plumber()
    .pipe $.pug
      locals: require("#{paths.src}/pug/data")
      pretty: true
    .pipe gulp.dest(paths.dist)

task_copy_assets = ->
  gulp.src "#{paths.src}/assets/**/*", { base: paths.src }
    .pipe gulp.dest(paths.dist)

task_copy_projects = ->
  gulp.src "./projects/**/*", { base: './' }
    .pipe gulp.dest(paths.dist)

task_copy_misc = ->
  gulp.src("#{paths.src}/miscellaneous/**/*",
    { base: "#{paths.src}/miscellaneous" })
    .pipe gulp.dest(paths.dist)

exports.copy = task_copy = gulp.parallel(task_copy_assets,
                                         task_copy_projects,
                                         task_copy_misc)

exports.clean = task_clean = del.bind(null, [paths.dist])

task_server = ->
  config =
    contentBase: paths.dist
    proxy: require './proxy'
    stats:
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false

  webpack_dev_runner = webpack webpackConfig(debug_option)
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

  gulp.watch ['src/pug/**/*'], gulp.series(task_pug, reload)
  gulp.watch ['src/pug/data.coffee'], gulp.series(task_pug, reload)
  gulp.watch ['src/assets/**/*'], gulp.series(task_copy_assets, reload)
  gulp.watch ['src/miscellaneous/**'], gulp.series(task_copy_misc, reload)

task_webpack = (cb) ->
  webpack webpackConfig(debug_option), (err, stats) ->
    throw new $.util.PluginError('webpack', err) if err
    $.util.log '[webpack_debug]', stats.toString({
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false
    })
    cb()

exports.build = gulp.series(task_clean,
                            gulp.parallel(task_pug,
                                          task_copy,
                                          task_webpack))

exports.serve = gulp.series(task_clean,
                            gulp.parallel(task_pug,
                                          task_copy,
                                          task_server))

# ############################################
# # test
# ############################################

exports.test = task_test = ->
  gulp.src 'src/coffee/test/*', { read: false }
    .pipe $.mocha({
      reporter: 'nyan'
      compilers: 'coffee:coffee-script/register'
    })

# ############################################
# # dist
# ############################################

task_prod_webpack = (cb) ->
  webpack webpackConfig(prod_option), (err, stats) ->
    throw new $.util.PluginError('webpack', err) if err
    $.util.log '[webpack]', stats.toString({
      colors: true
      timings: true
      assets: true
      hash: true
      chunks: false
    })
    cb()

task_prod_pug = ->
  pug_data = require "#{paths.src}/pug/data"
  manifest_data = require "#{paths.dist}/manifest.json"

  pug_data.manifest = {}
  pug_data.manifest[key] = v for key, v of manifest_data

  gulp.src "#{paths.src}/pug/[^_]*.pug"
    .pipe $.plumber()
    .pipe $.pug
      locals: pug_data
    .pipe gulp.dest(paths.dist)

exports['prod:build'] =
task_prod_build = gulp.series(task_test,
                              task_clean,
                              gulp.parallel(task_prod_webpack, task_copy),
                              task_prod_pug)

exports.default =
exports.dist = task_prod_build
