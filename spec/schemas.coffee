tv4 = require 'tv4'
tv4Formats = require 'tv4-formats'
chai = require 'chai' if not chai
yaml = require 'js-yaml'
path = require 'path'

lib = require '../index'

describe 'Schemas', ->
  schemas = []
  validator = tv4.freshApi()
  before ->
    validator.addFormat tv4Formats
  after ->
    validator.reset()
    validator.dropSchemas()

  lib.listSchemas().forEach (schemaName) ->
    schema = lib.getSchema schemaName
    validator.addSchema schema.id, schema
    schemas.push schema

  schemas.forEach (schema) ->
    describe "#{schema.id} (#{schema.title})", ->
      try
        cases = lib.getExamples path.basename schema.id, path.extname schema.id
      catch e
        it.skip "does not have examples"
        return

      cases.forEach (testcase) ->

        describe "#{testcase._name}", ->
          validator.addSchema schema.id, schema
          if testcase._valid
            it "should be valid", ->
              results = validator.validateMultiple testcase._data, schema.id
              chai.expect(results.errors).to.eql []
              chai.expect(results.missing).to.eql []
              chai.expect(results.valid).to.equal true
          else
            it "should be invalid", ->
              results = validator.validateMultiple testcase._data, schema.id
              chai.expect(results.errors).to.not.eql []
              chai.expect(results.missing).to.eql []
              chai.expect(results.valid).to.equal false

