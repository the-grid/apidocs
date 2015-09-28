
https = require 'https'

# Some configurations needed to talk with The Grid API
config =
  host: 'api.thegrid.io'
  port: 443
  path: '/share'

# @url: http(s) URL to publicly available website
# @compress: true means share an article reference, false means import full page content
shareUrl = (url, compress, accessToken, callback) ->
  # Data to be shared
  data =
    url: url
    compress: compress

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

  req = https.request opts, (res) =>
    return callback res
  req.write jsonData
  req.end()

exports.main = main = () ->
  unless process.argv.length > 2
    console.log "Usage: thegrid-share-url.coffee http://example.com/foo [nocompress]"
    process.exit 1
  url = process.argv[2]
  nocompress = process.argv[3] and process.argv[3] != 'compress'

  token = process.env.THEGRID_TOKEN
  unless token
    console.log 'Missing authentication token. Must be configured as environment variable THEGRID_TOKEN'
    process.exit 2

  shareUrl url, !nocompress, token, (res) ->
    if res.statusCode > 202
      console.log 'Error sharing'
      process.exit 3
    console.log "Shared '#{url}': #{res.headers.location}"

main() if not module.parent

