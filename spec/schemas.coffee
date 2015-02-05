
tv4 = require 'tv4'
chai = require 'chai' if not chai
yaml = require 'js-yaml'

path = require 'path'
fs = require 'fs'

schemaPath = '../schema'
getSchema = (name) ->
  filepath = path.join __dirname, schemaPath, name
  loadSchema filepath

loadSchema = (filepath) ->
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return JSON.parse content

getExamples = (name) ->
  filepath = path.join __dirname, '../examples', name+'.yml'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return yaml.safeLoad content

describe 'Schemas', ->
  before: ->
    metaSchema = loadSchema path.join __dirname, 'json-schema.json'
    tv4.addSchema 'http://json-schema.org/draft-04/schema', metaSchema
  after: ->
    tv4.reset()

  schemas = fs.readdirSync path.join __dirname, schemaPath
  schemas.forEach (schemaFile) ->
    schema = getSchema schemaFile
    tv4.addSchema schema.id, schema
    schemaName = path.basename schemaFile, '.json'

    describe schema.title, ->
      try
        cases = getExamples schemaName
      catch e
        return

      cases.forEach (testcase) ->

        describe "#{testcase._name}", ->
          tv4.addSchema schema.id, schema
          if testcase._valid
            it "should be valid", ->
              results = tv4.validateMultiple testcase._data, schema.id
              chai.expect(results.errors).to.eql []
          else
            it "should be invalid", ->
              results = tv4.validateMultiple testcase._data, schema.id
              chai.expect(results.errors).to.not.eql []

