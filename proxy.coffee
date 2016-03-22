Proxy =
  '/api/*':
    target: 'http://localhost:3000/'
    # rewrite proxyed url, removing '/api'
    rewrite: (req) ->
      req.url = req.url.replace /^\/api/, ''
    secure: false

exports = module.exports = Proxy
