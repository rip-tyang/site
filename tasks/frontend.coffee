# Include Gulp & Tools We'll Use
require('coffee-script/register')
gulp = require('gulp')
$ = require('gulp-load-plugins')()
browserSync = require('browser-sync')
reload = browserSync.reload
del = require('del')
runSequence = require('run-sequence')

## swap these two lines if you have a runnable backend in 'back' folder
# this will compile your frontend stuff into back/public and
# run it with your own server instead of browser-sync

is_backend = false
# is_backend = true

## compiling config
coffee_config =
  # bare: false
  bare: true
fingerprint_config =
  mode: 'replace'
  prefix: '/'

## files and paths
dev_dir = if is_backend is true then 'back/public' else 'front/dev'
dist_dir = if is_backend is true then 'back/public' else 'front/dist'

sources = {}
sources.jade =
  path: 'jade/'
  files: '*.jade'
  prefix: ''
sources.coffee =
  path: 'coffee/'
  files: '*.coffee'
  prefix: '/js'
sources.sass =
  path: 'sass/'
  files: '*.sass'
  prefix: '/css'
sources.assets =
  path: 'assets/'
  files: '**'
  prefix: '/assets'
sources.miscellaneous =
  path: 'miscellaneous/'
  files: '**'
  prefix: '/'
sources.manifest_assets =
  path: ''
  files: 'rev-manifest.assets.json'
  prefix: ''
sources.manifest_jscss =
  path: ''
  files: 'rev-manifest.jscss.json'
  prefix: ''
sources.lib =
  path: 'bower_components/**/'
  files: '*.min.js'
  prefix: '/lib'

for type, config of sources
  config.files = "front/#{config.path}#{config.files}"
  config.path = "front/#{config.path}"
  config.dev_dest = dev_dir + config.prefix
  config.dist_dest = dist_dir + config.prefix

## compile jade
gulp.task 'jade_dev', ->
  gulp.src sources.jade.files
    .pipe $.plumber()
    .pipe $.jade
      pretty: true
    .pipe gulp.dest(sources.jade.dev_dest)

## compile and compress
# read the manifest file and
# replace revisioned sources url (everything in assets folder, js folder and css folder)
# no revision happens to html files
gulp.task 'jade_dist', ->
  manifest = require("../#{sources.manifest_jscss.files}")
  assets_manifest = require("../#{sources.manifest_assets.files}")
  for url, dest of assets_manifest
    manifest[url] = dest

  gulp.src sources.jade.files
    .pipe $.jade
      pretty: false
    # use manifest file to replace revisioned sources
    .pipe $.fingerprint manifest, fingerprint_config
    .pipe gulp.dest(sources.jade.dist_dest)

## compile coffee
gulp.task 'coffee_dev', ->
  gulp.src sources.coffee.files
    .pipe $.plumber()
    .pipe $.sourcemaps.init()
    .pipe $.coffee(coffee_config).on('error', $.util.log)
    .pipe $.sourcemaps.write('./')
    .pipe gulp.dest(sources.coffee.dev_dest)

## compile and compress
# read the manifest file and
# replace revisioned sources url (everything in assets folder, js folder and css folder)
# do revision on itself
# TODO concate maybe, but need explicit dependencies for each js file
gulp.task 'coffee_dist', ->
  manifest = require("../#{sources.manifest_assets.files}")
  gulp.src sources.coffee.files
    .pipe $.coffee(coffee_config).on('error', $.util.log)
    # use manifest file to replace revisioned sources
    .pipe $.fingerprint manifest, fingerprint_config
    .pipe $.uglify()
    # do revision
    .pipe $.rev()
    .pipe gulp.dest(sources.coffee.dist_dest)
    # add revision source map to manifest
    .pipe $.rev.manifest
      path: sources.manifest_jscss.files
      merge: true
    .pipe gulp.dest('./')

## compile compass
gulp.task 'compass_dev', ->
  gulp.src sources.sass.files
    .pipe $.compass
      sass: sources.sass.path
      css: sources.sass.dev_dest
      sourcemap: true

## compile and compress
# read the manifest file and
# replace revisioned sources url (everything in assets folder, js folder and css folder)
# do revision on itself
# TODO change to sass grammar
gulp.task 'compass_dist', ->
  manifest = require("../#{sources.manifest_assets.files}")
  gulp.src sources.sass.files
    .pipe $.compass
      sass: sources.sass.path
      # there are something creepy, you must have a css file as a middle result
      # so I put it into cache folder
      css: '.sass-cache/css'
      style: 'compressed'
      sourcemap: true
    # use manifest file to replace revisioned sources
    .pipe $.fingerprint manifest, fingerprint_config
    # do revision
    .pipe $.rev()
    .pipe gulp.dest(sources.sass.dist_dest)
    # add revision source map to manifest
    .pipe $.rev.manifest
      path: sources.manifest_jscss.files
      merge: true
    .pipe gulp.dest('./')

## copy assets
gulp.task 'copy_dev', ->
  gulp.src sources.assets.files
    .pipe gulp.dest(sources.assets.dev_dest)

## copy assets
# do revision on itself
gulp.task 'copy_dist', ->
  gulp.src sources.assets.files
    # do revision
    .pipe $.rev()
    .pipe gulp.dest(sources.assets.dist_dest)
    # add revision source map to manifest
    .pipe $.rev.manifest
      path: sources.manifest_assets.files
      merge: true
    .pipe gulp.dest('./')
  gulp.src sources.miscellaneous.files
    .pipe gulp.dest(sources.miscellaneous.dist_dest)

## move bower libs into a folder in a flatten structure
gulp.task 'move_bower_dev', ->
  gulp.src sources.lib.files
    .pipe $.flatten()
    .pipe gulp.dest(sources.lib.dev_dest)

## the same as dev
gulp.task 'move_bower_dist', ->
  gulp.src sources.lib.files
    .pipe $.flatten()
    .pipe gulp.dest(sources.lib.dist_dest)

gulp.task 'clean', del.bind(null, ['front/rev-manifest*', dev_dir, dist_dir])

## server on the dev environment
gulp.task 'serve', ['jade_dev', 'coffee_dev', 'compass_dev', 'copy_dev', 'move_bower_dev'], ->
  if !is_backend
    browserSync
      notify: false
      logPrefix: 'Dev'
      # Run as an https by uncommenting 'https: true'
      # Note: this uses an unsigned certificate which on first access
      #       will present a certificate warning in the browser.
      # https: true,
      server:
        baseDir: dev_dir

  gulp.watch(['front/jade/**/*'], ['jade_dev', reload])
  gulp.watch(['front/sass/**/*.sass'], ['compass_dev', reload])
  gulp.watch(['front/coffee/*.coffee'], ['coffee_dev', reload])
  gulp.watch(['front/assets/**/*'], ['copy_dev', reload])
  gulp.watch(['front/bower_components/**'], ['move_bower_dev', reload])

## release
gulp.task 'release', ['clean'], (cb) ->
  # The runSequence is required, revision source replacing requires a sequencial execution.
  runSequence ['copy_dist', 'move_bower_dist'],
    'coffee_dist',
    'compass_dist',
    'jade_dist',
    cb

## server on the release environment
gulp.task 'default', ['release'], ->
  if !is_backend
    browserSync
      notify: false
      logPrefix: 'Dist'
      server:
        baseDir: dist_dir
