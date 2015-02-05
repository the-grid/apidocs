
tv4 = require 'tv4'
chai = require 'chai' if not chai
yaml = require 'js-yaml'

path = require 'path'
fs = require 'fs'

getSchema = (name) ->
  filepath = path.join __dirname, '../schemata', name+'.yaml'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return yaml.safeLoad content

getExamples = (name) ->
  filepath = path.join __dirname, '../examples', name+'.yml'
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return yaml.safeLoad content

describe 'Schemas', ->

  describe 'Site config', ->
    id = 'siteconfig'
    cases = getExamples id
    schema = getSchema id

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

