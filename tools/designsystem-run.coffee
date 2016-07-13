
jsjob = require 'jsjob'
fs = require 'fs'
path = require 'path'

readPolyfill = (name) ->
  p = path.join __dirname, '../jsjobs/polyfills', name
  return fs.readFileSync p, 'utf-8'

polyFillFunctionBind = readPolyfill 'function-bind.js'
polyCompat = readPolyfill 'polysolvepage.js'

startRunner = (options, callback) ->
  options.scripts = [
    polyFillFunctionBind,
    polyCompat
  ]
  runner = new jsjob.Runner options
  runner.start (err) ->
    return callback err, runner

runJob = (runner, filterUrl, data, callback) ->
  jobOptions = data.options
  jobOptions = {} if not jobOptions
  runner.runJob filterUrl, data, jobOptions, (err, outpage) ->
    if err
      return callback err
    unless outpage
      return callback new Error "JsJob returned falsy and no Error"
    return callback null, outpage

usageError = (msg) ->
  new Error "#{msg}\nUsage: thegrid-designsystem-run designsystem-url file"

parse = (args) ->
  if args.length < 2
    throw usageError "Wrong number of arguments, got #{args.length}, expected 2."

  minimist = require 'minimist'
  parseOptions =
    boolean: []
    default:
      output: 'html'
  parsed = minimist args, parseOptions

  parsed.designsystem = parsed._[0]
  parsed.file = parsed._[1]

  return parsed

collectStream = (s, callback) ->
  data = ""
  s.on 'error', (err) ->
    return callback err
  s.on 'data', (d) ->
    data += d.toString()
  s.on 'end', () ->
    return callback null, data
  s.read()


readInput = (file, callback) ->
  if file == '-'
    return collectStream process.stdin, callback
  else
    s = fs.createReadStream file, { encoding: 'utf-8' }
    return collectStream s, callback

startAndRun = (data, options, outerCallback) ->
  runner = null
  callback = (err, r, d) ->
    if runner
      runner.stop (e) ->
        return outerCallback err, r, d
    else
      return outerCallback err, r, d

  startRunner options, (err, r) ->
    runner = r
    return callback err if err
    return runJob runner, options.designsystem, data, callback

main = () ->
  options = parse process.argv.slice(2)

  callback = (err, results, details) ->
    if err
      console.error err
      process.exit 1
    else
      if options.output
        results = results[options.output]
      console.log results
      process.exit 0
  
  readInput options.file, (err, input) ->
    return callback err if err
    return callback new Error 'Input did not contain data' if not input
    data = JSON.parse input
    return startAndRun data, options, callback

module.exports.main = main
