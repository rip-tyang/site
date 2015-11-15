webpack = require 'webpack'
path = require 'path'
nib = require 'nib'
banner = 'Copyright 2015 Thomas Yang http://thomas-yang.me/'

paths =
  src: path.join(__dirname, 'src')
  dest: path.join(__dirname, 'dist')

module.exports =
  entry: [
    'webpack/hot/dev-server',
    'webpack-dev-server/client?http://localhost:5000',
    paths.src + '/coffee/main.coffee'
  ]
  watch: true
  debug: true
  devtool: 'eval'
  output:
    path: paths.dest
    filename: 'main.js'
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
        loader: 'style-loader!css-loader!stylus-loader'
      },
      {
        test: /\.(eot|ttf|woff)$/
        loader: 'url?limit=100000'
      }
    ],

  stylus:
    use: [nib()]
  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.BannerPlugin(banner)
  ]
