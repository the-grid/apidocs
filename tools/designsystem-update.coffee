#     TheGrid API docs example code
#     (c) 2015 TheGrid (Rituwall Inc.)
#     May be freely distributed under the MIT license

jwt = require 'jsonwebtoken'
semver = require 'semver'

https = require 'https'
http = require 'http'
url = require 'url'
querystring = require 'querystring'

post = (u, type, body, callback) ->
    options = url.parse u
    options.headers =
      'Content-Type': type
      'Content-Length': body.length
    options.method = 'POST'
    client = if options.protocol is 'https:' then https else http

    # avoid firing callback multiple times
    returned = false
    doCallback = (err, result) ->
      return if returned # already fired
      returned = true
      return callback err, result

    req = client.request options, (res) ->
      returned = true
      return callback res
    req.on 'error', (error) ->
      req.abort()
      return doCallback new Error(error.message)
    req.setTimeout 2000, ->
      req.abort()
      return doCallback new Error 'Request timeout'
    req.write body
    req.end()

sign = (secret, p) ->
    payload =
      type: 'new_version'
      version: p.version
      url: p.url
      designsystem: p.designsystem
      preventAutosolve: p.preventAutosolve
    signed = jwt.sign payload, secret

newVersion = (secret, payload, callback) ->
  signed = sign secret, payload

  body =
    jwt: signed
    designsystem: payload.designsystem
  body = querystring.stringify body

  endpoint = 'https://api.thegrid.io/designsystem_event'
  post endpoint, 'application/x-www-form-urlencoded', body, (res) ->
    status = res.statusCode
    return callback new Error "Update not accepted by API: #{status}" if status != 202
    return callback null, payload 

parse = (args) ->
  if args.length < 3
    throw new Error "Wrong number of arguments. Expected 3+ (name version url [preventAutosolve]), got #{args}"

  payload =
    designsystem: args[0]
    version: args[1]
    url: args[2]
  payload.preventAutoSolve = args[3].toLowerCase() == 'preventautosolve' if args[3]

  return payload

validate = (o) ->
  return o.designsystem and
    o.url.indexOf('https') != -1 and
    semver.valid(o.version)

exports.main = ->
  # Note: secret scoped to a particular design system
  secret = process.env.DEPLOY_SECRET
  payload = parse process.argv.slice(2)

  if not validate payload
    throw new Error "Invalid options: #{JSON.stringify(payload, null, 2)}"

  newVersion secret, payload, (err, r) ->
    throw err if err
    console.log "Updated #{r.designsystem} to version #{r.version}: #{r.url}"
    

