random = require 'otw/like/_/random'
type = require 'otw/like/_/type'
randexp = do () ->
  _randexp = require 'randexp'
  (pattern) -> new _randexp(pattern).gen()


module.exports = exports = (schema, options = {}) ->
  options.root_schema = schema

  generator = new exports.Generator options
  return generator.generate()

class exports.Generator

  constructor: (options) ->
    @method = options.method
    @root_schema = options.root_schema

  generate: (schema = null, depth = 0) ->

    schema = @root_schema unless schema

    return schema  unless type(schema) is 'object'

    return @enum schema, depth  if schema.enum

    if schema.$ref
      return @ref schema.$ref, depth

    switch schema.type
      when 'string', 'number', 'integer', 'boolean', 'array', 'object', 'null'
        return @[schema.type] schema, depth
      else
        if type(schema.type) is 'array'
          return @oneOf schema, depth
        # FIXME what if type(schema.type) = 'object' and _.size(schema.type) > 0 ?
        if schema.type is 'any' or type(schema.type) is 'undefined' or (type(schema.type) is 'object' and _.size(schema.type) is 0)
          return @any schema, depth
        # FIXME what type is this?
        console.log schema.type
        throw "what type is this ?"


  # enum
  'enum': (schema, depth = 0) ->
    randomOptions =
      minimum: 0
      maximum: schema.enum.length - 1
    randomIndex = random 'integer', randomOptions
    enumValue = schema.enum[randomIndex]
    @generate enumValue, depth + 1


  # type = null
  'null': () ->
    null


  # type = boolean
  boolean: (schema, depth = 0) ->
    random 'boolean'


  # type = number / integer
  number: (schema, depth = 0) ->
    @integer schema, depth

  integer: (schema, depth = 0) ->
    minimum = schema.exclusiveMinimum + 1  if schema.exclusiveMinimum
    minimum ?= schema.minimum
    maximum = schema.exclusiveMaximum - 1  if schema.exclusiveMaximum
    maximum ?= schema.maximum
    decimals = 0
    decimals = random 'number', {minimum: 0, maximum: 3}  if schema.type is 'number'

    randomOptions =
      minimum: minimum
      maximum: maximum
      divisibleBy: schema.divisibleBy
      decimals: decimals
    random 'number', randomOptions


  # type = string
  string: (schema, depth = 0) ->
    return randexp schema.pattern  if schema.pattern
    # FIXME format should not be ignored
    randomOptions =
      minLength: schema.minLength
      maxLength: schema.maxLength
    random 'string', randomOptions


  # type = array
  array: (schema, depth = 0) ->
    o = []

    if type(schema.items) is 'object' and schema.items.$ref
      result = @ref schema.items.$ref, depth
      return [result]

    if type(schema.items) is 'array' and schema.items.length
      for itemSchema in schema.items
        o.push @generate itemSchema, depth + 1

    if schema.additionalItems
      if type(schema.minItems) isnt 'undefined'
        minimum = schema.minItems - o.length
      else
        minimum = 1
      minimum = 1  if minimum < 0
      # minimum set to 1, not 0, on purpose
      if type(schema.maxItems) isnt 'undefined'
        maximum = schema.maxItems - o.length
      else
        maximum = o.length + random 'integer', {minimum: 0, maximum: 2}
      randomOptions =
        minimum: minimum
        maximum: maximum
      howManyMoreItems = random 'integer', randomOptions
      while howManyMoreItems
        howManyMoreItemsLeft = howManyMoreItems - o.length
        if howManyMoreItemsLeft
          for i in [1..howManyMoreItemsLeft]
            o.push @generate schema.additionalItems, depth + 1
          o = _.deepUnique o  if schema.uniqueItems
        howManyMoreItemsLeft = howManyMoreItems - o.length
        break  unless howManyMoreItemsLeft
    o


  # type = object
  object: (schema, depth = 0) ->
    o = {}
    for key, prop of schema.properties
      continue  unless @method is 'all' or (type(schema.required) is 'array' and key in schema.required)
      # FIXME
      # continue  if random 'boolean'
      o[key] = @generate prop, depth + 1

    if type(schema.additionalProperties) is 'object'
      # break  if schema.additionalProperties.$ref?[0] is '#'
      randomOptions =
        minimum: 1
        maximum: 3
        # minimum set to 1, not 0, on purpose
      howManyMoreProperties = random 'integer', randomOptions
      for i in [0..howManyMoreProperties]
        o[random 'string', {minimum: 0, maximum: 10}] = @generate schema.additionalProperties, depth+1

    else if schema.additionalProperties isnt false
      o[random 'string', {minimum: 0, maximum: 10}] = @generate {type: 'any'}, depth+1

    return o


  # type = any
  any: (schema, depth = 0) ->
    types = ['string', 'number', 'integer', 'boolean', 'object', 'null']
    randomOptions =
      minimum: 0
      maximum: types.length-1
    typeIndex = random 'integer', randomOptions
    @generate {type: types[typeIndex]}, depth + 1


  # type = []
  oneOf: (schema, depth = 0) ->
    return 0  unless schema.type.length # treat as 'any'
    randomOptions =
      minimum: 0
      maximum: schema.type.length-1
    typeIndex = random 'integer', randomOptions
    @generate schema.type[typeIndex], depth + 1


  ref: (ref, depth = 0) ->
    path = ref.split('/')
    if path[0] != '#'
      throw "ref does not start with #: " + ref

    schema = @root_schema
    for name in path.slice(1)
      schema = schema[name]
      if not schema
        throw "$ref traversal failed: " + ref

    return @generate schema, depth
