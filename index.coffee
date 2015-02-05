
yaml = require 'js-yaml'
path = require 'path'
fs = require 'fs'

path = require 'path'
fs = require 'fs'

schemaPath = './schema'

exports.listSchemas = () ->
  files = fs.readdirSync path.join __dirname, schemaPath
  names = (path.basename f, '.json' for f in files)
  return names

exports.getSchema = (name) ->
  filepath = path.join __dirname, schemaPath, name+'.json'
  exports.loadSchema filepath

exports.loadSchema = (filepath) ->
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return JSON.parse content

exports.getExamples = (name) ->
  filepath = path.join __dirname, './examples', name+'.yml'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return yaml.safeLoad content
