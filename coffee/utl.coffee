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

