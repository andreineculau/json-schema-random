generate = do () ->
  _generate = require './index'
  () -> console.log _generate.apply @, arguments

generate {type: 'number'}
generate {type: 'integer'}
generate {type: 'string'}
generate {type: 'string', pattern: 'a+1+'}
generate {type: 'array'}
generate {type: 'array', items: [{type: 'string'}], additionalItems: {type: 'boolean'}}
