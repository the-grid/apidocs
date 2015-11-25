#     TheGrid API docs example code
#     (c) 2015 TheGrid (Rituwall Inc.)
#     May be freely distributed under the MIT license

jwt = require 'jsonwebtoken'
semver = require 'semver'

https = require 'https'
http = require 'http'
url = require 'url'
querystring = require 'querystring'

apiBase = "https://api.thegrid.io"
apiBase = process.env.THEGRID_API if process.env.THEGRID_API?

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

setCollaborators = (secret, payload, callback) ->
  signedPayload =
    type: 'set_collaborators'
    designsystem: payload.designsystem 
    collaborators: payload.collaborators
  signed = jwt.sign signedPayload, secret
  body =
    jwt: signed
    designsystem: payload.designsystem
  body = querystring.stringify body

  endpoint = "#{apiBase}/designsystem_event"
  post endpoint, 'application/x-www-form-urlencoded', body, (res) ->
    status = res.statusCode
    return callback new Error "Update not accepted by API: #{status}: #{body}" if status != 202
    return callback null, payload 

parse = (args) ->
  if args.length != 2
    throw new Error "Wrong number of arguments. Expected 2:\n designsystem <collaboratorAuuid,collaboratorB...>\nGot '#{args}'"

  minimist = require 'minimist'
  parseOptions =
    boolean: []
    default: {}
  parsed = minimist args, parseOptions

  parsed.designsystem = parsed._[0]
  uuids = parsed._[1].split ','
  parsed.collaborators = uuids

  return parsed

validUuid = (str) ->
  regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  matches = str.match regex
  return matches? and matches.length == 1

validate = (o) ->
  throw new Error 'collaborators is undefined' if not o.collaborators
  throw new Error 'Must have least have 1 collaborator' if not o.collaborators.length > 1
  invalid = o.collaborators.filter (c) -> !validUuid(c)
  throw new Error "Following collaborators are invalid UUIDs #{JSON.stringify(invalid)}" if invalid.length > 0
  return o

exports.main = ->
  # Note: secret scoped to a particular design system
  secret = process.env.DEPLOY_SECRET
  payload = parse process.argv.slice(2)
  validate payload

  setCollaborators secret, payload, (err, r) ->
    throw err if err
    console.log "Set collaborators for #{r.designsystem} to #{r.collaborators}"
    

