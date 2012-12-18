# repeat {{{
repeat = (end, func)->
  idx = 0
  if _.isNumber end
    _repeat = ->
      _.defer -> func(idx); _repeat() if ++idx < end
    _repeat() if idx < end
  else if _.isArray end
    collection = end
    end = collection.length
    _repeat = ->
      _.defer -> func(collection[idx]); _repeat() if ++idx < end
    _repeat() if idx < end
# }}}
# debug {{{
info = ->
  console.info.apply(console,arguments) if debug? and debug
log = ->
  console.log.apply(console,arguments) if debug? and debug
df = (name,env)-> # debug function
  console.info( name,env.constructor.name ) if debug? and debug
#}}}
