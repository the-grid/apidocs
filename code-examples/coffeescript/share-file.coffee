
https = require "https"
FormData = require "form-data"
uuid = require "uuid"
fs = require "fs"

shareFile = (filePath, accessToken, callback) ->
  formData = new FormData()
  # It's interesting to use a valid UUID to keep track of the shared item
  # If you have a canonical URL, use that instead
  formData.append "url", "content://#{uuid.v4()}"
  formData.append "type", "image/jpeg" # FIXME: don't hardcode
  formData.append "content", fs.createReadStream(filePath)
  opts =
    host: "api.thegrid.io"
    port: 443
    path: "/share"
    method: "POST"
    headers: formData.getHeaders()
  # Add your `accessToken` to headers
  opts.headers["Authorization"] = "Bearer #{accessToken}"

  req = https.request opts
  formData.pipe req

  req.on "response", (result) ->
    callback result

exports.main = main = () ->
  unless process.argv.length > 2
    console.log "Usage: coffee share-file.coffee myfile.png"
    process.exit 1
  fileToShare = process.argv[2]

  token = process.env.THEGRID_TOKEN
  unless token
    console.log 'Missing authentication token. Must be configured as environment variable THEGRID_TOKEN'
    process.exit 2

  shareFile fileToShare, token, (res) ->
    if res.statusCode > 202
      console.log 'Error sharing '
      process.exit 3
    console.log "Finished sharing '#{fileToShare}': #{res.headers.location}"

main() if not module.parent

