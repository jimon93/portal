do ($ = jQuery)->
  # sortreload {{{
  $.Mason::sortreload = (callback)->
    #@reloadItems()
    @$bricks = @_getBricks @element.children()
    @$bricks = @$bricks.get().sort (l,r)->
      lv = $(l).data("gadget").get('priority')
      rv = $(r).data("gadget").get('priority')
      if lv <= rv then (if lv < rv then -1 else 0 ) else 1
    @$bricks = $( @$bricks )
    @_init( callback )
  # }}}

