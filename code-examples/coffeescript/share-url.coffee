OAuth2 = require('oauth').OAuth2
express = require 'express'
https = require 'https'

# Some configurations needed to talk with The Grid API
config =
  host: 'api.thegrid.io'
  port: 443
  path: '/share'
  app_id: process.env.THEGRID_APP_ID or ''
  app_secret: process.env.THEGRID_APP_SECRET or ''
  scopes: ['share']
  authorization_url: 'https://passport.thegrid.io/login/authorize'
  token_url: 'https://passport.thegrid.io/login/authorize/token'
  callback_url: 'http://localhost:3000/authenticated'

# Data to be shared
data =
  url: 'https://flowhub.io'
  compress: true

# The Grid API supports OAuth2 authentication
oauth = new OAuth2(
  config.app_id
  config.app_secret
  ''
  config.authorization_url
  config.token_url
  null
)

# Create an app that will redirect us to The Grid `config.authorization_url` and
# then back to our `config.callback_url`
app = express()

app.get '/', (req, res) ->
  oauthURL = oauth.getAuthorizeUrl
    redirect_uri: config.callback_url
    scope: config.scopes
    response_type: 'code' 

  body = "<a href=\"#{oauthURL}\">Share on The Grid</a>"

  res.send body

app.get '/authenticated', (req, res) ->
  oauth.getOAuthAccessToken(
    req.query.code
    {'redirect_uri': config.callback_url, 'grant_type': 'authorization_code'}
    (err, accessToken, refreshToken, results) ->
      if err?
        res.send "Error: #{err}"
      if results.error?
        res.send "Error: #{JSON.stringify(results)}"
      # Receive the token for this session at `accessToken`
      jsonData = JSON.stringify data
      opts =
        host: config.host
        port: config.port
        path: config.path
        method: 'POST'
        headers:
          Authorization: "Bearer #{accessToken}"
          'Content-Type': 'application/json'
          'Content-Length': jsonData.length
      # After having received the token we are good to share
      req = https.request opts, (result) =>
        if result.statusCode isnt 202
          res.send "Error: #{res.statusCode}"
        res.send "Content shared!"
      req.write jsonData
      req.end()
  )

app.listen 3000
console.log "Share your content at http://localhost:3000"
