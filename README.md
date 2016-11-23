
The Grid API documentation
==========================

Documentation for the public APIs of [The Grid](https://thegrid.io).

The latest built version is at [developer.thegrid.io](http://developer.thegrid.io)

For corrections, improvements file issues or pull requests in the
[the-grid/apidocs on Github](https://github.com/the-grid/apidocs).

## Commandline tools

Several code examples are available as command-line tools, and can be useful for scripting, testing or development.
You will need to have [node.js](http://nodejs.org) installed.

To install

    npm install -g thegrid-apidocs

Examples:

    thegrid-authenticate             # get a The Grid user token, for use with the other tools
    
    thegrid-share-file myfile.jpg    # share a file on disk to The Grid
    thegrid-share-url http://coolblog.org/nifty.html                 # share article
    thegrid-share-url http://myoldsite.com/article.html nocompress   # import all content of URL

    thegrid-site-configure http://mygridsite.com colors   # show site config (here for colors)
    thegrid-site-configure http://mygridsite.com name "My new name"   # set site config (here website title)

Schemas
--------

In addition to the human-readable documentation, a set of [JSON Schema](https://json-schema.org)s are provided.
These can can be used to validate payloads, generate test-cases etc.

You can install or depend on these using NPM

    npm install thegrid-apidocs

JavaScript validation example (using [tv4 library](https://github.com/geraintluff/tv4))

    var tv4 = require('tv4');
    var apidocs = require('thegrid-apidocs');

    var myPost = ....
    var postSchema = apidocs.getSchema('item');
    var valid = tv4.validate(myPost, postSchema);

Some of our schemas provide user-friendly error messages. To enable them, load the custom error reporter:

    apidocs.enableCustomErrors(tv4);

Blueprints
----------

The descriptions of HTTP APIs are using [Blueprint](https://apiblueprint.org/)
found in [./blueprint](./blueprint). These are human-readable but can also be
used to set up mock servers etc using the various tools that consume Blueprint.


Tests & examples
-----------

The schemas are tested for correctness using data-driven tests.
Each of the `valid` and `invalid` [./examples](./examples),
creates a testcase which ensures that the schema classifies it correctly.

The same examples are referenced in the Blueprint docs.
