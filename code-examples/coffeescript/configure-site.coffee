
https = require "https"

getConfig = (accessToken, sitePath, callback) ->
  opts =
    host: "api.thegrid.io"
    port: 443
    path: sitePath
    method: "GET"
    headers: {}
  # Add your `accessToken` to headers
  opts.headers["Authorization"] = "Bearer #{accessToken}"

  body = ""
  req = https.request opts
  req.on "response", (res) ->
    return callback new Error res.statusCode if res.statusCode != 200
    res.on 'data', (d) ->
      body += d.toString()
    res.on 'end', () ->
      try
        config = JSON.parse body
      catch e
        return callback e
      return callback null, config
  req.end()

setConfig = (accessToken, sitePath, site, callback) ->
  opts =
    host: "api.thegrid.io"
    port: 443
    path: sitePath
    method: "PUT"
    headers: {}
  # Add your `accessToken` to headers
  opts.headers["Authorization"] = "Bearer #{accessToken}"

  json = JSON.stringify site
  opts.headers['Content-Type'] = 'application/json'
  opts.headers['Content-Length'] = json.length
  req = https.request opts
  req.write json
  req.on "response", (res) ->    
    return callback new Error res.statusCode if res.statusCode != 200
    return callback null, site
  #console.log 'set', sitePath, '\n', site
  req.end()

updateConfig = (token, sitePath, newConfig, callback) ->
  # To avoid loosing other config values, we fetch existing config first
  getConfig token, sitePath, (err, site) ->
    return callback err if err
    console.log 'newconfig', newConfig
    for k, v of newConfig
      site.config[k] = v
    setConfig token, sitePath, site, callback

lookupSiteId = (accessToken, siteUrl, callback) ->
  opts =
    host: "api.thegrid.io"
    port: 443
    method: "GET"
    path: "/site/discover?url=#{encodeURIComponent(siteUrl)}"
    headers: {}
  opts.headers["Authorization"] = "Bearer #{accessToken}"

  req = https.request opts
  req.on 'response', (res) ->
    return callback new Error res.statusCode if res.statusCode != 302
    return callback null, res.headers.location
  req.end()

parseValue = (val) ->
  return undefined if val == 'undefined'
  return null if val == 'null'
  try
    return JSON.parse val
  catch e
    v = parseFloat val
    return v if not isNaN v
  return val

main = () ->
  unless process.argv.length > 2
    console.log "Usage: coffee configure-site.coffee siteUrl [key] [value]"
    process.exit 1
  siteUrl = process.argv[2]
  key = process.argv[3]
  value = process.argv[4]

  token = process.env.THEGRID_TOKEN
  unless token
    console.log 'Missing authentication token. Must be configured as environment variable THEGRID_TOKEN'
    process.exit 2

  lookupSiteId token, siteUrl, (err, siteId) ->
    throw err if err

    if key and value
      value = parseValue value
      c = {}
      c[key] = value
      updateConfig token, siteId, c, (err, config) ->
        throw err if err
        console.log "Set #{key} to #{value}"
    else
      getConfig token, siteId, (err, config) ->
        throw err if err
        console.log config

main() if not module.parent

