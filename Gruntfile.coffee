module.exports = ->
  # Project configuration
  pkg = @file.readJSON 'package.json'
  repo = pkg.repository.url.replace 'git://', 'https://'+process.env.GH_TOKEN+'@'

  @initConfig
    pkg: @file.readJSON 'package.json'

    # Coding standards
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

    'gh-pages':
      options:
        base: 'browser'
        clone: 'gh-pages'
        message: 'Updating'
        repo: repo
        user:
          name: 'NoFlo bot'
          email: 'bot@noflo.org'
        silent: true
      src: '**/*'

  # Grunt plugins used for building

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-mocha-test'

  # Grunt plugins used for deploying
  @loadNpmTasks 'grunt-gh-pages'

  # Our local tasks
  @registerTask 'build', 'Build', (target = 'all') =>
    # TODO: build .yaml schemas into .json
    # TODO: build HTML from schemas and examples

  @registerTask 'test', 'Build and run tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'mochaTest'

  @registerTask 'default', ['test']

