OAuth2 = require("oauth").OAuth2
express = require "express"
https = require "https"

authApp = (config, authCallback) ->
  # The Grid API supports OAuth2 authentication
  oauth = new OAuth2(
    config.app_id
    config.app_secret
    ""
    config.authorization_url
    config.token_url
    null
  )

  # Create an app that will redirect us to The Grid `config.authorization_url` and
  # then back to our `config.callback_url`
  app = express()

  app.get "/", (req, res) ->
    oauthURL = oauth.getAuthorizeUrl
      redirect_uri: config.callback_url
      scope: config.scopes
      response_type: "code"

    body = "<a href=\"#{oauthURL}\">Authenticate with The Grid</a>"
    res.send body

  app.get "/authenticated", (req, res) ->
    oauth.getOAuthAccessToken(
      req.query.code
      {"redirect_uri": config.callback_url, "grant_type": "authorization_code"}
      (err, accessToken, refreshToken, results) ->
        authCallback err, results, accessToken
        if err?
          res.send "Error: #{err}"
        if results.error?
          res.send "Error: #{JSON.stringify(results)}"
        # Receive the token for this session at `accessToken`
        res.send "Success, token printed to console"
    )

  return app

main = () ->
  console.log "Usage: coffee auth.coffee [scope1] [scope2] ..."

  if process.argv.length == 2
    scopes = ["share"]
  else
    scopes = process.argv.slice 2

  # Some configurations needed to talk with The Grid API
  config =
    app_id: process.env.THEGRID_APP_ID or ""
    app_secret: process.env.THEGRID_APP_SECRET or ""
    scopes: scopes
    authorization_url: "https://passport.thegrid.io/login/authorize"
    token_url: "https://passport.thegrid.io/login/authorize/token"
    callback_url: "http://localhost:3000/authenticated"

  app = authApp config, (err, results, token) ->
    console.log 'Authenticated: ', err, results, token
    console.log "export THEGRID_TOKEN=#{token}" if token

  app.listen 3000
  console.log "Authenticate at http://localhost:3000"

main() if not module.parent
