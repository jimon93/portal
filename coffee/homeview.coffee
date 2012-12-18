class HomeBaseView extends BaseView

# HomeView {{{
class HomeView extends HomeBaseView
  id:"home"
  className:"container"
  containerSelector: ">.row"
  templateString:"<div class='row' />"

  initialize: ->
    super
    @subView = new HomeSubView { collection: @collection }
    @gadgetIframes = new GadgetIframes { collection: @collection }
    @router.on("all",@routes)

  routes:->
    switch super
      when 'home', 'gadget' then @render()
      else @remove()

  render:->
    if !@rendering
      @$el.appendTo( $("body") )
      super
      @container().append @subView.render().$el
      @container().append @gadgetIframes.render().$el
      @rendering = true
      return @

  remove:->
    if @rendering
      @subView.remove()
      @gadgetIframes.remove()
      @rendering = false
      super
# }}}
# HomeSubView {{{
class HomeSubView extends HomeBaseView
  className: "sub"

  initialize: ->
    super
    @homeViewSwitch = new HomeViewSwitch()
    @gadgetNavs = new GadgetNavs { collection: @collection }

  appendChildView:->
    @$el.append @homeViewSwitch.render().$el
    @$el.append @gadgetNavs.render().$el

  deligateEvent:->
    @listenTo( @home       , "change:mode"  , @onHome )
    @listenTo( @router     , "route:home"   , @onHome )
    @listenTo( @router     , "route:gadget" , @onGadget )
    @listenTo( @responsive , "change:size"  , @onWindow )

  rendered:->
    @router.refire( "route:home"   , @onHome )
    @router.refire( "route:gadget" , @onGadget )

  onHome:->
    next = switch @home.get('mode')
      when 'list' then 12
      when 'grid' then switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 12
    @resize( next )

  onGadget:->
    next = switch @responsive.get('size')
      when 'large', 'desktops' then 3
      when 'tablets', 'phones' then 0
    @resize( next )

  onWindow:->
    @router.refire( "route:home", @onHome )
    @router.refire( "route:gadget", @onGadget )

  remove:->
    @homeViewSwitch.remove()
    @gadgetNavs.remove()
# }}}
# HomeViewSwitch {{{
class HomeViewSwitch extends HomeBaseView
  id: "home-view-switch"
  className: [ "btn-toolbar", "hidden-phone" ].join(" ")
  templateSelector: "#templates>#home-view-switch-tmpl"
  events: {
    "click a": "switch"
  }

  deligateEvent:->
    @listenTo( @home   , "change:mode"  , @onMode )
    @listenTo( @router , "route:home"   , @onMode )
    @listenTo( @router , "route:gadget" , @onFocus )

  renderd:->
    @router.refire( "route:home", @onMode )
    @router.refire( "route:gadget", @onGadget )

  switch:(e)->
    mode = $(e.currentTarget).data("mode")
    @home.set("mode", mode)
    @router.navigate("/", {trigger:true})
    return false

  onMode:->
    @$("##{@home.previous('mode')}").removeClass("active")
    @$("##{@home.get('mode')}").addClass("active")

  onFocus:->
    @$("##{@home.get('mode')}").removeClass("active")
# }}}
# GadgetNavs {{{
class GadgetNavs extends HomeBaseView
  tagName   : 'ul'
  id        : "gadgets-nav"
  className : [ "nav", "nav-tabs", "nav-stacked" ].join(' ')

  initialize: ->
    super
    @$el.sortable @sortable_options()
    @$el.disableSelection()

  deligateEvent:->
    @listenTo( @collection, 'reset', @render )
    @listenTo( @collection, 'add', @add )

  getChildView: _.memoize(
    (model)-> new GadgetNavsItem {model}
    (model)-> model.id
  )

  sortable_options : -> {
    cursor : 'move'
    opacity: 0.9
    axis:'y'
    update:(e,ui)=>
      @$el.children().each (i)-> $(@).data('gadget').set('priority',i)
      @collection.trigger('sorted',@collection)
  }
# }}}
# GadgetNavsItem {{{
class GadgetNavsItem extends HomeBaseView
  tagName: 'li'
  templateSelector: "#gadget-navs-item"

  initialize : ->
    super
    @$el.data("gadget",@model)

  deligateEvent:->
    @listenTo( @router , "route:home"   , @noActive )
    @listenTo( @router , "route:gadget" , @active )
    @listenTo( @model  , "remove"       , @remove )

  rendered:->
    @router.refire( "route:home"  , @noActive )
    @router.refire( "route:gadget", @active )

  noActive:(focus)->
    @$el.removeClass("active")

  active:(focus)->
    @$el[if parseInt(focus) == @model.id then "addClass" else "removeClass"]("active")
# }}}
# GadgetIframes {{{
class GadgetIframes extends HomeBaseView
  id: "gadgets"
  className: "main"
  containerSelector:".row"
  templateString:"<div class='row' />"

  initialize: -> #{{{
    super
    $.iframeMonitor.option { callback : _.bind(@replace,@,{silent:false}) }
    #@replace = _.throttle @replace, 100
  #}}}
  deligateEvent:->
    @listenTo( @collection , 'add'          , @add      )
    @listenTo( @collection , 'sorted'       , @replace  )
    @listenTo( @home       , "change:mode"  , @onHome   )
    @listenTo( @router     , "route:home"   , @onHome   )
    @listenTo( @router     , "route:gadget" , @onGadget )
    @listenTo( @responsive , "change:size"  , @onWindow )

  rendered:->
    @router.refire( "route:home"   , @onHome )
    @router.refire( "route:gadget" , @onGadget )

  add:(model)-> #{{{
    child = super
    child.on("change:height", @replace )
    child.on("delete", @collection.remove, @collection)
    @replace()
  #}}}
  getChildView: _.memoize( #{{{
    (model)-> new GadgetIframe { model }
    (model)-> model.id
  )
  #}}}
  onHome:->
    next = switch @home.get('mode')
      when 'list' then 0
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 9
          when 'tablets' then 8
          when 'phones' then 0
    @resize( next )
    _.defer @replace

  onGadget:(focus)->
    next = switch @responsive.get('size')
      when 'large', 'desktops' then 9
      when 'tablets', 'phones' then 12
    @resize( next )
    _.defer @replace

  onWindow:->
    @router.refire( "route:home", @onHome )
    @router.refire( "route:gadget", @onGadget )

  replace: ( opt = {silent:true} )-> #{{{
    log "replace", opt
    container = @container()
    if not container.is(".masonry")
      container.masonry { itemSelector: '.gadget:visible', isAnimated: true }
    container.masonry 'option', {isAnimated: false} if opt.silent
    container.masonry('sortreload')
    container.masonry 'option', {isAnimated: true}  if opt.silent
  #}}}
# }}}
# GadgetIframe {{{
class GadgetIframe extends HomeBaseView
  tagName: 'div'
  className: "gadget"
  templateSelector: "#templates #gadget-header"

  events:{
    "click .title": -> @menu.toggle()
  }

  initialize : ->
    super
    # field
    @menu = new GadgetMenu { model: @model }
    # init
    @$el.data 'gadget', @model

  appendChildView:->
    @$el.append @menu.render().$el
    _.defer @appendIframe

  deligateEvent:->
    @listenTo( @model  , "remove"          , @onRemove )
    @listenTo( @router , "route:home"      , @onMinimize )
    @listenTo( @router , "route:gadget"    , @onMinimize )
    @listenTo( @router , "route:home"      , @onHome )
    @listenTo( @router , "route:gadget"    , @onGadget )
    @listenTo( @menu   , "show"            , @changedHeight )
    @listenTo( @menu   , "hide"            , @changedHeight )
    @listenTo( @menu   , "change:minimize" , @onMinimize )
    @listenTo( @menu   , "delete"          , @delete )

  rendered:->
    @router.refire( "route:home"   , @onHome )
    @router.refire( "route:gadget" , @onGadget )

  appendIframe:->
    @$el.append "<div class='content'/>"
    @$('.content').iframe( @makeSrc() ).monitor()
    log "appendIframe"
    @changedHeight({silent:true})

  onHome:->
    next = switch @home.get('mode')
      when 'list' then 0
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 0
    @resize( next )

  onGadget:(focus)->
    next = switch parseInt( focus )
      when @model.id
        switch @responsive.get('size')
          when 'large', 'desktops' then 9
          when 'tablets','phones' then 12
      else 0
    @resize( next )

  makeSrc:-> #{{{
    """
    <!DOCTYPE html>
    <html>
    <head>
    <link rel="stylesheet" href="/css/bootstrap.css">
    <link rel="stylesheet" href="/css/bootstrap-responsive.css">
    <style> body </style>
    <script src="/js/jquery-1.8.3.js"></script>
    </head>
    <body>
    #{@model.get 'content'}
    </body>
    </html>
    """
  #}}}
  onRemove:-> #{{{
    @remove()
    if @home.get('focus') == @model.id
      next = if @home.get("mode") == "grid" then "" else "list"
      @router.navigate(next,{ trigger: true })
    else
      @changedHeight({silent:false})
  #}}}
  changedHeight:(opt = {silent:true})-> #{{{
    log "changedHeight", opt
    @trigger("change:height",)
  #}}}
  onMinimize:-> #{{{
    if @home.get("focus")?
      if @home.get("focus") == @model.id
        @$(".content").show()
        @$(".title .navbar-inner").removeClass("single")
    else if @home.get("mode") == 'grid'
      mode = @menu.minimizeMode
      @$(".content")[if mode then "hide" else "show"]()
      @$(".title .navbar-inner")[if mode then "addClass" else "removeClass"]("single")
  #}}}
  delete:-> #{{{
    @trigger("delete",@model)
  #}}}
  remove:->
    $.iframeMonitor.remove @$("iframe")[0]
    @menu.remove()
    super
# }}}
# GadgetMenu {{{
class GadgetMenu extends HomeBaseView
  className: [ "menu", "well", "collapse" ].join(" ")
  templateSelector: "#templates>#gadget-menu"

  events: {
    "click .config"   : "config"
    "click .resize"   : "resize"
    "click .minimize" : "minimize"
    "click .maximize" : "maximize"
    "click .delete"   : "delete"
    "show"            : "onShow"
    "hide"            : "onHide"
  }

  initialize: ->
    super
    @minimizeMode = false
    @$el.collapse({toggle:false})

  deligateEvent:->
    @listenTo( @home, "change:mode" ,@update)
    @listenTo( @home, "change:focus",@update)
    @listenTo( @home, "change:mode" ,@fastHide)
    @listenTo( @home, "change:focus",@fastHide)

  rendered:->
    @update()

  toggle:->
    @$el.collapse("toggle")

  update:->
    if @home.get("focus")?
      @$(".resize"  ).hide()
      @$(".minimize").hide()
      @$(".maximize").hide()
    else if @home.get('mode') == "grid"
      @$(".resize"  )[if @minimizeMode then 'show' else 'hide']()
      @$(".minimize")[if @minimizeMode then 'hide' else 'show']()
      @$(".maximize").show()

  config:->
    @$el.collapse("hide")

  resize:->
    @minimizeMode = false
    @update()
    @trigger("change:minimize",false)
    @$el.collapse("hide")

  minimize:->
    @minimizeMode = true
    @update()
    @trigger("change:minimize",true)
    @$el.collapse("hide")

  maximize:->
    @fastHide()

  delete:->
    @trigger("delete")

  fastHide:->
    @$el.height(0).removeClass("in")

  onShow: ->
    @$el.height("auto")
    @trigger("show")
    @$el.height(0)

  onHide: ->
    @$el.hide()
    @trigger("hide")
    @$el.show()
#}}}
