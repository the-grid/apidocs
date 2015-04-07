path = require 'path'

module.exports = ->
  # Project configuration
  pkg = @file.readJSON 'package.json'
  repo = pkg.repository.url.replace 'git://', 'https://'+process.env.GH_TOKEN+'@'

  @initConfig
    pkg: @file.readJSON 'package.json'

    yaml:
      schemas:
        files: [
          expand: true
          cwd: 'schemata/'
          src: '*.yaml'
          dest: 'schema/'
        ]

    aglio:
      blueprint:
        files:
          'dist/index.html': ['blueprint/index.apib']
          'dist/authentication.html': ['blueprint/authentication.apib']
          'dist/passport.html': ['blueprint/passport.apib']
          'dist/api.html': ['blueprint/api.apib']
        options:
          includePath: __dirname
          theme: 'slate'

    # Coding standards
    yamllint:
      schemas: ['schemata/*.yaml']
      examples: ['examples/*.yml']

    coffeelint:
      components: ['Gruntfile.coffee', 'spec/*.coffee']
      options:
        'max_line_length':
          'level': 'ignore'

    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'

    copy:
      schemas:
        files: [
          expand: true, src: ['schema/*.json'], dest: 'dist/', filter: 'isFile'
        ]
      cname:
        files: [
          src: ['CNAME'], dest: 'dist/'
        ]
      favicon:
        files: [
          src: ['favicon.ico'], dest: 'dist/'
        ]

    'gh-pages':
      options:
        base: 'dist'
        clone: 'gh-pages'
        message: 'Updating'
        repo: repo
        user:
          name: 'Grid bot'
          email: 'bot@thegrid.io'
        silent: true
      src: '**/*'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-yaml'
  @loadNpmTasks 'grunt-aglio'
  @loadNpmTasks 'grunt-contrib-copy'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-yamllint'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-mocha-test'

  # Grunt plugins used for deploying
  @loadNpmTasks 'grunt-gh-pages'

  # Custom task for generating JSON files for valid examples to be included in Blueprint
  @registerTask 'build_examples', 'Create files for examples', =>
    examples = @file.expand ['examples/*.yml']
    examples.forEach (e) =>
      data = @file.readYAML e
      return unless data
      basename = path.basename e, '.yml'
      for d in data
        continue unless d._name
        filename = "examples/#{basename}-#{d._name}.json"
        @file.write filename, JSON.stringify d._data, null, 2
        @log.writeln "Created example file '#{filename}'"

  # Our local tasks
  @registerTask 'build', 'Build', (target = 'all') =>
    @task.run 'yaml'
    @file.mkdir 'dist'
    @task.run 'copy'
    @task.run 'build_examples'
    @task.run 'aglio'

  @registerTask 'test', 'Build and run tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'yamllint'
    @task.run 'build'
    @task.run 'mochaTest'

  @registerTask 'default', ['test']

