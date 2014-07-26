# JSON Schema random

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
npm install json-schema-random
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

## Command-line options

`--no-additional` - don't generate fields for `additionalProperties`

`--no-random` - return blank values instead of random

# License

Apache 2.0
