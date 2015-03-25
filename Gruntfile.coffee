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

    exec:
      schemas_to_html:
        command: './node_modules/json-schema-docs-generator/bin/generate.js'

    aglio:
      blueprint:
        files:
          'dist/passport.html': ['blueprint/passport.apib']
          'dist/api.html': ['blueprint/api.apib']
        options:
          includePath: __dirname

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
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-aglio'
  @loadNpmTasks 'grunt-contrib-copy'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-yamllint'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-mocha-test'

  # Grunt plugins used for deploying
  @loadNpmTasks 'grunt-gh-pages'

  # Our local tasks
  @registerTask 'build', 'Build', (target = 'all') =>
    @task.run 'yaml'
    @file.mkdir 'dist'
    @task.run 'exec'
    @task.run 'copy'
    @task.run 'aglio'

  @registerTask 'test', 'Build and run tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'yamllint'
    @task.run 'build'
    @task.run 'mochaTest'

  @registerTask 'default', ['test']

