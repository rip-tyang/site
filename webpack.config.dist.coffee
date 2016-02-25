webpack = require 'webpack'
path = require 'path'
nib = require 'nib'
stylus = require 'stylus'
ManifestPlugin = require 'webpack-manifest-plugin'
banner = 'Copyright 2015 Thomas Yang http://thomas-yang.me/'

paths =
  src: path.join(__dirname, 'src')
  dest: path.join(__dirname, 'dist')

module.exports =
  entry: [
    paths.src + '/coffee/main.coffee'
  ]
  output:
    path: paths.dest
    filename: 'main.[hash].js'
  resolve:
    # you can now require('file') instead of require('file.coffee')
    extensions: ['', '.js', '.json', '.coffee', '.css', '.styl']
  module:
    loaders: [
      {
        test: /\.coffee$/
        exclude: /node_modules/
        loader: 'coffee-loader'
      },
      {
        test: /\.styl$/
        loader: 'style-loader!css-loader!stylus-loader?resolve url'
      },
      {
        test: /\.(eot|ttf|woff)$/
        loader: 'url?limit=100000'
      }
    ],

  stylus:
    use: [nib()]
    define:
      url: stylus.url
        paths: [__dirname + '/src']
        limit: false

  plugins: [
    new ManifestPlugin(),
    new webpack.BannerPlugin(banner),
    new webpack.optimize.UglifyJsPlugin
      compress: true
      mangle: true
  ]
