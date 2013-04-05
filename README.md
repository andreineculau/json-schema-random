# JSON Schema generator

Given a JSON Schema (draft 04), provide a random valid instance.

# Disclaimer

This is an choppy piece of software, that is in need of some care and affection.

# TODO

* format
* uniqueItems
* $ref
* patternProperties
* dependencies
* allOf
* anyOf
* oneOf
* not

# Install

```bash
npm install git://github.com/andreineculau/json-schema-random.git#v0.0.x
```

# Usage

```bash
# Return a generated JSON instance to stdout of the JSON_SCHEMA_FILE
json-schema-random JSON_SCHEMA_FILE
```

```coffee
# Or, in your source code
generate = require 'json-schema-random'
generate {type: 'number'}
```

# License

Apache 2.0
