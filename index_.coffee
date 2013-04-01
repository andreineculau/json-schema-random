random = require 'otw/like/_/random'
type = require 'otw/like/_/type'

module.exports = generate = (schema, method = 'all', depth = 0) ->
  return schema  unless type(schema) is 'object'

  switch schema.type
    when 'string'
      if schema.enum
        randomOptions =
          minimum: 0
          maximum: schema.enum.length - 1
        randomIndex = random 'integer', randomOptions
        enumValue = schema.enum[randomIndex]
        return generate enumValue, method, depth + 1
      # FIXME format should not be ignored
      randomOptions =
        minLength: schema.minLength
        maxLength: schema.maxLength
      return random 'string', randomOptions
    when 'number', 'integer'
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
      return random 'number', randomOptions
    when 'boolean'
      return random 'boolean'
    when 'array'
      o = []
      if type(schema.items) is 'array' and schema.items.length
        for itemSchema in schema.items
          o.push generate itemSchema, method, depth + 1
      else if type(schema.items) is 'object'
        # FIXME items should not be a schema, really
        console.log schema.items
        throw "items should not be a schema, really"

      if schema.additionalItems
        break  if schema.additionalItems.$ref?[0] is '#'
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
          for i in [1..howManyMoreItemsLeft]
            o.push generate schema.additionalItems, method, depth + 1
          o = _.deepUnique o  if schema.uniqueItems
          howManyMoreItemsLeft = howManyMoreItems - o.length
          break  unless howManyMoreItemsLeft

      return o
    when 'object'
      o = {}
      for key, prop of schema.properties
        continue  unless method is 'all' or (type(schema.required) is 'array' and key in schema.required)
        # FIXME
        # continue  if random 'boolean'
        o[key] = generate prop, method, depth + 1

      if type(schema.additionalProperties) is 'object'
        break  if schema.additionalProperties.$ref?[0] is '#'
        randomOptions =
          minimum: 1
          maximum: 3
          # minimum set to 1, not 0, on purpose
        howManyMoreProperties = random 'integer', randomOptions
        for i in [0..howManyMoreProperties]
          o[random 'string', {minimum: 0, maximum: 10}] = generate schema.additionalProperties, method, depth+1

      else if schema.additionalProperties isnt false
        o[random 'string', {minimum: 0, maximum: 10}] = generate {type: 'any'}, method, depth+1

      return o  unless depth is 0 and schema.mediaType

      return o
    when 'null'
      return null
    else
      # FIXME what if type(schema.type) = 'object' and _.size(schema.type) > 0 ?
      if schema.type is 'any' or type(schema.type) is 'undefined' or (type(schema.type) is 'object' and _.size(schema.type) is 0)
        types = ['string', 'number', 'integer', 'boolean', 'object', 'null']
        randomOptions =
          minimum: 0
          maximum: types.length-1
        typeIndex = random 'integer', randomOptions
        return generate {type: types[typeIndex]}, method, depth + 1
      if type(schema.type) is 'array'
        return 0  unless schema.type.length # treat as 'any'
        randomOptions =
          minimum: 0
          maximum: schema.type.length-1
        typeIndex = random 'integer', randomOptions
        return generate schema.type[typeIndex], method, depth + 1
      # FIXME what type is this?
      console.log schema.type
      throw "what type is this ?"
