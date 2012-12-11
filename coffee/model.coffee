Config = Backbone.Model.extend {
  initialize:(object,usage)->
    if usage? and usage.length > 0
      keys = _(object).keys()
      diff = _.difference( keys, usage )
      @unset key for key in diff
}

Gadget = Backbone.Model.extend {
  initialize:->
    config = @get('config')
    @unset 'config', {silent:true}
    @set   'mod-config'  , new Config( config.mod ), {silent:true}
    @set   'user-config' , new Config( config.user , config.usage_option )

  save:->
    @get('user-config').save()
}

Gadgets = Backbone.Collection.extend {
  model: Gadget

  comparator:(gadget)->
    gadget.get('priority')
}

Responsive = Backbone.Model.extend {
  initialize:->
    _.bindAll @, 'resize'
    $(window).resize @resize
    @resize()

  resize: (e)->
    width = $(window).width()
    prevSize = @get( 'size' )
    nextSize = if width >= 1200
      'large'
    else if width >= 980
      'desktops'
    else if width >= 768
      'tablets'
    else
      'phones'
    @set( 'size', nextSize )
    @trigger( 'changed:size', @ ) if prevSize != nextSize
    #console.log 'responsive', width, @get('size')
}
