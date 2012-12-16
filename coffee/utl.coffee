# repeat {{{
repeat = (end, func)->
  idx = 0
  if _.isNumber end
    _repeat = ->
      setTimeout (-> func(idx); _repeat() if ++idx < end) ,1
    _repeat() if idx < end
  else if _.isArray end
    collection = end
    end = collection.length
    _repeat = ->
      setTimeout (-> func(collection[idx]); _repeat() if ++idx < end) ,1
    _repeat() if idx < end
# }}}
# debug {{{
info = ->
  console.info.apply(console,arguments) if debug? and debug
log = ->
  console.log.apply(console,arguments) if debug? and debug
df = (name,env)-> # debug function
  console.info( "#{name}::#{env.constructor.name}", env ) if debug? and debug
#}}}
