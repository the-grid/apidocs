tv4 = require 'tv4'
tv4Formats = require 'tv4-formats'
lib = require '../index'
chai = require 'chai' if not chai

describe 'Custom errors', ->
  schemas = {}
  validator = null
  before ->
    validator = tv4.freshApi()
    validator.addFormat tv4Formats
    lib.enableCustomErrors validator
    lib.listSchemas().forEach (schemaName) ->
      schema = lib.getSchema schemaName
      validator.addSchema schema.id, schema
      schemas[schemaName] = schema
  after ->
    validator.dropSchemas()
    validator.reset()

  describe 'invalid repo name', ->
    it 'should produce a custom error', (done) ->
      baseSchema = schemas['base']
      chai.expect(baseSchema.definitions.site.messages).to.be.an 'object'
      chai.expect(baseSchema.definitions.site.messages.pattern).to.exist
      result = validator.validateMultiple
        name: 'The Grid'
        repo: 'foo'
        path: '/foo'
      , 'site.json'
      chai.expect(result.valid).to.equal false
      chai.expect(result.errors[0].message).to.equal baseSchema.definitions.site.messages.pattern
      done()
