
tv4 = require 'tv4'
chai = require 'chai' if not chai
yaml = require 'js-yaml'

path = require 'path'
fs = require 'fs'

getSchema = (name) ->
  filepath = path.join __dirname, '../schema', name+'.json'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return JSON.parse content

getExamples = (name) ->
  filepath = path.join __dirname, '../examples', name+'.yml'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return yaml.safeLoad content

schemas =
  'siteconfig': 'Site config'
  'contentblock': 'Content block'

describe 'Schemas', ->

  Object.keys(schemas).forEach (schemaName) ->
    description = schemas[schemaName]

    describe description, ->
      cases = getExamples schemaName
      schema = getSchema schemaName

      cases.forEach (testcase) ->

        describe "#{testcase._name}", ->
          if testcase._valid
            it "should be valid", ->
              results = tv4.validateMultiple testcase._data, schema
              chai.expect(results.errors).to.eql []
          else
            it "should be invalid", ->
              results = tv4.validateMultiple testcase._data, schema
              chai.expect(results.errors).to.not.eql []

