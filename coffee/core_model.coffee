class Config extends BaseModel
  initialize:(object,usage)->
    if usage? and usage.length > 0
      keys = _(object).keys()
      diff = _.difference( keys, usage )
      @unset key for key in diff

class Gadget extends BaseModel
  initialize:->
    config = @get('config')
    @unset 'config', {silent:true}
    @set   'mod-config'  , new Config( config.mod ), {silent:true}
    @set   'user-config' , new Config( config.user , config.usage_option )

  save:->
    @get('user-config').save()

class Gadgets extends Backbone.Collection
  model: Gadget

  comparator:(gadget)->
    gadget.get('priority')

class Responsive extends BaseModel
  initialize:->
    _.bindAll @, 'resize'
    @debounce_resize = _.debounce( @resize, 100 )
    $(window).resize @debounce_resize
    @resize()

  resize: (e)->
    width = $(window).width()
    nextSize = if width >= 1200
      'large'
    else if width >= 980
      'desktops'
    else if width >= 768
      'tablets'
    else
      'phones'
    @set( 'size', nextSize )
