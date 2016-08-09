webpack = require 'webpack'
path = require 'path'
nib = require 'nib'
stylus = require 'stylus'
ManifestPlugin = require 'webpack-manifest-plugin'
banner = 'Copyright 2015 Thomas Yang http://thomas-yang.me/'

paths =
  src: path.join(__dirname, 'src')
  dest: path.join(__dirname, 'dist')

debugPlugins = [
  new webpack.HotModuleReplacementPlugin()
  new webpack.BannerPlugin(banner)
]

productionPlugins = [
  new ManifestPlugin()
  new webpack.BannerPlugin(banner)
  new webpack.optimize.UglifyJsPlugin({
    sourceMap: false
    compress: true
    mangle: true
  })
]

baseOption =
  output:
    path: paths.dest
  resolve:
    # you can now require('file') instead of require('file.coffee')
    extensions: ['', '.js', '.json', '.coffee', '.css', '.styl']
  module:
    loaders: [
      {
        test: /\.coffee$/
        exclude: /node_modules/
        loader: 'coffee-loader'
      }
      {
        test: /\.styl$/
        loader: 'style-loader!css-loader!stylus-loader'
      }
      {
        test: /\.(eot|ttf|woff|otf|svg)$/
        loader: 'url?limit=100000'
      }
    ]

  stylus:
    use: [nib()]
    define:
      'inline-url': stylus.url
        paths: [__dirname + '/src']
        limit: false

makeEntry = (obj) ->
  throw Error 'no entry files' unless obj.entry?.length > 0
  r = {}
  obj.entry.forEach (e) -> r[e] = ["#{paths.src}/coffee/#{e}.coffee"]
  if obj.isDebug
    hotServer = 'webpack/hot/dev-server'
    reloadServer = "webpack-dev-server/client?http://localhost:#{obj.port}"
    for k, v of r
      v.unshift reloadServer
      v.unshift hotServer
  r

createOption = (obj = {}) ->
  throw Error 'specify how to build: debug or production' unless obj.build?
  obj.isDebug = obj.build isnt 'production'

  obj.port = obj.port || 5000
  option = Object.create baseOption
  option.entry = makeEntry obj

  if obj.isDebug
    option.watch = true
    option.debug = true
    option.devtool = 'cheap-module-source-map'
    option.output.filename = '[name].js'
    option.plugins = debugPlugins
  else
    option.output.filename = '[name].[hash].js'
    option.plugins = productionPlugins

  option

module.exports = createOption
