class HomeBaseView extends BaseView

# HomeView {{{
class HomeView extends HomeBaseView
  id:"home"
  className:"container"
  containerSelector: ">.row"

  initialize: ->
    df( "initialize", @ )
    super
    # field
    @subView = new HomeSubView { collection: @collection }
    @gadgetIframes = new GadgetIframes { collection: @collection }
    # events
    @router.on("all",@routes)

  routes:->
    df( "routes", @ )
    switch super
      when 'home', 'gadget' then @render()
      else @remove()

  render:->
    if !@rendered
      df( "render", @ )
      @$el.appendTo( $("body") )
      super
      @$el.append("<div class='row' />")
      @container().append @subView.render().$el
      #@container().append @gadgetIframes.render().$el
      @rendered = true
      return @

  remove:->
    df( "remove", @ )
    if @rendered
      @subView.remove()
      @rendered = false
      @gadgetIframes.remove()
      super
# }}}
# HomeSubView {{{
class HomeSubView extends HomeBaseView
  className: "sub"

  initialize: ->
    df( "initialize", @ )
    super
    _.bindAll( @, "onHome", "onGadget" )
    # field
    @homeViewSwitch = new HomeViewSwitch()
    @gadgetNavs = new GadgetNavs { collection: @collection }

  render:->
    df( "render", @ )
    # rendering
    @$el.append @homeViewSwitch.render().$el
    @$el.append @gadgetNavs.render().$el
    # event
    @listenTo( @home       , "change:mode"  , @onHome )
    @listenTo( @router     , "route:home"   , @onHome )
    @listenTo( @router     , "route:gadget" , @onGadget )
    @listenTo( @responsive , "change:size"  , @resize )
    # init
    return @

  onHome:->
    next = switch @home.get('mode')
      when 'list' then 12
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 12
    @resize( next )

  onGadget:->
    next = switch @responsive.get('size')
      when 'large', 'desktops' then 3
      when 'tablets', 'phones' then 0
    @resize( next )

  remove:->
    @homeViewSwitch.remove()
    @gadgetNavs.remove()
    super
# }}}
# HomeViewSwitch {{{
class HomeViewSwitch extends HomeBaseView
  id: "home-view-switch"
  className: [
    "btn-toolbar"
    "hidden-phone"
  ].join(" ")
  templateSelector: "#templates>#home-view-switch-tmpl"

  events: {
    "click a": "switch"
  }

  initialize: ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @
      "switch"
      "onMode"
      "onFocus"
    )

  render:->
    df( "render", @ )
    super
    # event
    @listenTo( @home   , "change:mode"  , @onMode )
    @listenTo( @router , "route:home"   , @onMode )
    @listenTo( @router , "route:gadget" , @onFocus )
    return @

  switch:(e)->
    df( "switch", @ )
    mode = $(e.currentTarget).data("mode")
    @home.set("mode", mode)
    @router.navigate("/", {trigger:true})
    return false

  onMode:->
    df( "onMode", @ )
    @$("##{@home.previous('mode')}").removeClass("active")
    @$("##{@home.get('mode')}").addClass("active")

  onFocus:->
    df( "onFocus", @ )
    @$("##{@home.get('mode')}").removeClass("active")
# }}}
# GadgetNavs {{{
class GadgetNavs extends HomeBaseView
  tagName   : 'ul'
  id        : "gadgets-nav"
  className : [
    "nav"
    "nav-tabs"
    "nav-stacked"
  ].join(' ')

  initialize: ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll @, 'makeChildView'
    # init
    @$el.sortable @sortable_options()
    @$el.disableSelection()

  render:->
    super
    # event
    @listenTo( @collection, 'reset', @render )
    @listenTo( @collection, 'add', @add )
    return @

  makeChildView: _.memoize(
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

  remove:->
    child.remove() for cid, child of @children
    super
# }}}
# GadgetNavsItem {{{
class GadgetNavsItem extends HomeBaseView
  tagName: 'li'
  templateSelector: "#gadget-navs-item"

  initialize : ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @, 'active' )
    # field
    @$el.data("gadget",@model)
    # init
    @active()

  render:->
    super
    # event
    #@listenTo( @home, "change:focus",@active)
    @listenTo( @router, "route:home", @active )
    @listenTo( @router, "route:gadget", @active )
    @listenTo( @model, "remove", @remove )
    return @

  active:(focus)->
    df( "active", @ )
    focus = parseInt(focus)
    #focus = @home.get("focus")
    #console.log "active", @model.id, focus == @model.id
    @$el[if focus? and focus == @model.id then "addClass" else "removeClass"]("active")
# }}}
# GadgetIframes {{{
class GadgetIframes extends HomeBaseView
  id: "gadgets"
  className: "main"
  containerSelector:".row"
  initialize: -> #{{{
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @, 'replace')
    # init
    $.iframeMonitor.option { callback : @replace }
  #}}}
  render: -> #{{{
    df( "render", @ )
    super
    @$el.append("<div class='row' />")
    # event
    @listenTo( @collection, 'reset'        , @render )
    @listenTo( @collection, 'add'          , @add )
    @listenTo( @collection, 'sorted'       , @replace )
    @listenTo( @home      , "change:mode"  , @resize )
    @listenTo( @home      , "change:focus" , @resize )
    @listenTo( @responsive, "change:size"  , @resize )
    @collection.each @add
    return @
  #}}}
  add:(model)-> #{{{
    df( "add", @ )
    child = super
    child.on("change:height", @replace)
    child.on("delete", @collection.remove, @collection)
    @replace(false)
  #}}}
  makeChildView: _.memoize( #{{{
    (model)-> new GadgetIframe { model, parent:@ }
    (model)-> model.id
  )
  #}}}
  replace: (animate = true)-> #{{{
    df( "replace", @ )
    # 要リファクタリング
    _container = @container()
    if not _container.is(".masonry")
      _container.masonry { itemSelector: '.gadget:visible', isAnimated: true }
    if @home.get('focus')?
      _container.masonry 'option', {isAnimated: false}
      _container.masonry('sortreload')
      _container.masonry 'option', {isAnimated: true}
    else if @home.get("mode") == "grid"
      _container.masonry 'option', {isAnimated: false} if !animate
      _container.masonry('sortreload')
      _container.masonry 'option', {isAnimated: true}  if !animate
  #}}}
  resize:-> #{{{
    df( "resize", @ )
    next = if @home.get("focus")?
      switch @responsive.get('size')
        when 'large', 'desktops' then 9
        when 'tablets', 'phones' then 12
    else
      switch @home.get('mode')
        when 'list' then 0
        when 'grid'
          switch @responsive.get('size')
            when 'large', 'desktops' then 9
            when 'tablets' then 8
            when 'phones' then 0
    super next
    child.resize() for cid, child of @children
    @replace()
  #}}}

  remove:->
    child.remove() for cid, child of @children
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
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @
      'makeSrc'
      'onRemove'
      'changedHeight'
      'onMinimize'
      'delete'
    )
    # field
    @menu = new GadgetMenu { model: @model }
    # init
    @$el.data 'gadget', @model

  render:->
    df( "render", @ )
    super
    @$el.append @menu.render().$el
    @$el.append "<div class='content'/>"
    #@iframe = @$('.content').iframe(@makeSrc()).monitor()
    @resize()
    # event
    @listenTo( @model, "remove"          , @onRemove )
    @listenTo( @home , "change:mode"     , @onMinimize )
    @listenTo( @home , "change:focus"    , @onMinimize ) # resize と onMinimizeは統合するべきか
    @listenTo( @menu , "show"            , @changedHeight )
    @listenTo( @menu , "hide"            , @changedHeight )
    @listenTo( @menu , "change:minimize" , @onMinimize )
    @listenTo( @menu , "delete"          , @delete )
    return @

  resize:->
    df( "resize", @ )
    next = if @home.get('focus')?
      switch @home.get('focus')
        when @model.id
          switch @responsive.get('size')
            when 'large', 'desktops' then 9
            when 'tablets','phones' then 12
        else 0
    else
      switch @home.get('mode')
        when 'list' then 0
        when 'grid'
          switch @responsive.get('size')
            when 'large', 'desktops' then 3
            when 'tablets' then 4
            when 'phones' then 0
    super next

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
    df( "onRemove", @ )
    $.iframeMonitor.remove @$("iframe")[0]
    @remove()
    if @home.get('focus') == @model.id
      next = if @home.get("mode") == "grid" then "" else "list"
      @router.navigate(next,{ trigger: true })
    else
      @changedHeight(0)
  #}}}
  changedHeight:-> #{{{
    df( "changedHeight", @ )
    @trigger("change:height")
  #}}}
  onMinimize:-> #{{{
    df( "onMinimize", @ )
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
    df( "delete", @ )
    @trigger("delete",@model)
  #}}}
  remove:->
    @menu.remove()
    super
# }}}
# GadgetMenu {{{
class GadgetMenu extends HomeBaseView
  className: [
    "menu"
    "well"
    "collapse"
  ].join(" ")
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
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @
      'toggle'
      'update'
      'config'
      'resize'
      'minimize'
      'maximize'
      'delete'
      'fastHide'
      'onShow'
      'onHide'
    )
    # field
    @minimizeMode = false
    # init
    @$el.collapse({toggle:false})

  render:->
    super
    @update()
    # event
    @listenTo( @home, "change:mode" ,@update)
    @listenTo( @home, "change:focus",@update)
    @listenTo( @home, "change:mode" ,@fastHide)
    @listenTo( @home, "change:focus",@fastHide)
    return @

  toggle:->
    df( "toggle", @ )
    @$el.collapse("toggle")

  update:->
    df( "update", @ )
    if @home.get("focus")?
      @$(".resize"  ).hide()
      @$(".minimize").hide()
      @$(".maximize").hide()
    else if @home.get('mode') == "grid"
      @$(".resize"  )[if @minimizeMode then 'show' else 'hide']()
      @$(".minimize")[if @minimizeMode then 'hide' else 'show']()
      @$(".maximize").show()

  config:->
    df( "config", @ )
    @$el.collapse("hide")

  resize:->
    df( "resize", @ )
    @minimizeMode = false
    @update()
    @trigger("change:minimize",false)
    @$el.collapse("hide")

  minimize:->
    df( "minimize", @ )
    @minimizeMode = true
    @update()
    @trigger("change:minimize",true)
    @$el.collapse("hide")

  maximize:->
    df( "maximize", @ )
    @fastHide()

  delete:->
    df( "delete", @ )
    @trigger("delete")
    #collection.remove @model

  fastHide:->
    df( "fastHide", @ )
    @$el.height(0).removeClass("in")

  onShow: ->
    df( "onShow", @ )
    @$el.height("auto")
    #@parent.replace("show")
    @trigger("show")
    @$el.height(0)

  onHide: ->
    df( "onHide", @ )
    @$el.hide()
    #@parent.replace("hide")
    @trigger("hide")
    @$el.show()
#}}}
