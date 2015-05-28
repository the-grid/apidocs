
The Grid API documentation
==========================

Documentation for the public APIs of [The Grid](https://thegrid.io).

The latest built version is at [developer.thegrid.io](http://developer.thegrid.io)

For corrections, improvements file issues or pull requests in the
[the-grid/apidocs](https://github.com/the-grid/apidocs) Github repository.


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
