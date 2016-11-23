tv4 = require 'tv4'
chai = require 'chai' if not chai
path = require 'path'
fs = require 'fs'

schemaPath = '../schema'
getSchema = (name) ->
  filepath = path.join __dirname, schemaPath, name
  loadSchema filepath

loadSchema = (filepath) ->
  content = fs.readFileSync filepath, { encoding: 'utf-8' }
  return JSON.parse content

describe 'Schema meta validation', ->
  schemas = fs.readdirSync path.join __dirname, schemaPath
  schemaNames = []
  validator = tv4.freshApi()
  before ->
    metaSchema = loadSchema path.join __dirname, 'json-schema.json'
    validator.addSchema 'http://json-schema.org/draft-04/schema', metaSchema
  after ->
    validator.reset()
    validator.dropSchemas()
  schemas.forEach (schemaFile) ->
    schema = getSchema schemaFile
    validator.addSchema schema.id, schema
    schemaNames.push schema

  schemaNames.forEach (schema) ->
    describe "#{schema.id} (#{schema.title or schema.description})", ->
      it 'should validate against JSON meta schema', ->
        result = validator.validateMultiple schema, 'http://json-schema.org/draft-04/schema'
        chai.expect(result.missing).to.eql []
        chai.expect(result.errors).to.eql []
        chai.expect(result.valid).to.equal true
