class HomeBaseView extends BaseView

# HomeView {{{
class HomeView extends HomeBaseView
  containerSelector: ">.row"

  initialize: ->
    df( "initialize", @ )
    # field
    @subView = new HomeSubView { collection: @collection }
    @gadgetIframes = new GadgetIframes { collection: @collection }
    # init
    @render()

  render:->
    df( "render", @ )
    @$el.append("<div class='row' />")
    @container().append @subView.render()
    @container().append @gadgetIframes.render()
# }}}
# HomeSubView {{{
class HomeSubView extends HomeBaseView
  className: "sub"

  initialize: ->
    df( "initialize", @ )
    super
    # field
    @homeViewSwitch = new HomeViewSwitch()
    @gadgetNavs = new GadgetNavs { collection: @collection }
    # event
    @home.on       "change:mode", @resize
    @home.on       "change:focus", @resize
    @responsive.on "change:size", @resize

  render:->
    df( "render", @ )
    @$el.append @homeViewSwitch.render()
    @$el.append @gadgetNavs.render()
    return @$el

  resize:->
    df( "resize", @ )
    @$el.append @homeViewSwitch.render()
    next = if @home.get("focus")?
      switch @responsive.get('size')
        when 'large', 'desktops' then 3
        when 'tablets', 'phones' then 0
    else
      switch @home.get('mode')
        when 'list' then 12
        when 'grid'
          switch @responsive.get('size')
            when 'large', 'desktops' then 3
            when 'tablets' then 4
            when 'phones' then 12
    super next
# }}}
# HomeViewSwitch {{{
class HomeViewSwitch extends HomeBaseView
  #tagName: 'div'
  id: "home-view-switch"
  className: [
    "btn-toolbar"
    "hidden-phone"
  ].join(" ")
  templateSelector: "#templates #home-view-switch-tmpl"

  initialize: ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @
      "onMode"
      "onFocus"
    )
    # event
    @home.on "change:mode", @onMode
    @home.on "change:focus", @onFocus

  onMode:->
    df( "onMode", @ )
    @$("##{@home.previous('mode')}").removeClass("active")
    @$("##{@home.get('mode')}").addClass("active")

  onFocus:->
    df( "onFocus", @ )
    @$("##{@home.get('mode')}").removeClass("active") if @home.get("focus")?
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

    # event
    @collection.on 'reset', @render
    @collection.on 'add', @add

    # init
    @$el.sortable @sortable_options()
    @$el.disableSelection()
    #@render()

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
    # event
    #@home.on("change:mode",@active)
    @home.on("change:focus",@active)
    @model.on "remove", => @remove()
    # init
    @active()

  active:->
    df( "active", @ )
    focus = @home.get("focus")
    #console.log "active", @model.id, focus == @model.id
    @$el[if focus? and focus == @model.id then "addClass" else "removeClass"]("active")
# }}}
# GadgetIframes {{{
class GadgetIframes extends HomeBaseView
  id: "gadgets"
  className: "main"
  containerSelector:".row"

  initialize: ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @, 'replace')
    # event
    @collection.on 'reset', @render
    @collection.on 'add', @add
    @collection.on 'sorted', @replace
    @home.on "change:mode", @resize
    @home.on "change:focus", @resize
    @home.on "changed:mode", @replace
    @home.on "changed:focus", @replace
    @responsive.on "change:size", @resize
    @responsive.on 'changed:size', @replace
    # init
    $.iframeMonitor.option { callback : @replace }

  render: ->
    df( "render", @ )
    super
    @$el.append("<div class='row' />")
    @collection.each @add
    return @$el

  add:(model)->
    df( "add", @ )
    super
    @replace(false)

  makeChildView: _.memoize(
    (model)-> new GadgetIframe { model, parent:@ }
    (model)-> model.id
  )

  replace: (animate = true)->
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

  resize:->
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
# }}}
# GadgetIframe {{{
class GadgetIframe extends HomeBaseView
  tagName: 'div'
  className: "gadget"
  templateSelector: "#templates #gadget-header"

  events : {
    "click .title"            : "menuToggle"
    "click .menu .config>a"   : "menuConfig"
    "click .menu .resize>a"   : "menuResize"
    "click .menu .minimize>a" : "menuMinimize"
    "click .menu .maximize>a" : "menuMaximize"
    "click .menu .delete>a"   : "menuDelete"
  }

  initialize : ->
    df( "initialize", @ )
    super
    # bind
    _.bindAll( @
      'makeSrc'
      'onRemove'
      'menuToggle'
      'menuSet'
      'menuConfig'
      'menuResize'
      'menuMinimize'
      'menuMaximize'
      'menuDelete'
      'menuFastHide'
      'menuOnShow'
      'menuOnHide'
    )
    # field
    @parent = @options.parent
    # event
    @model.on "remove", @onRemove
    @home.on "change:mode", @resize
    #@home.on 'change:mode', @menuSet
    @home.on 'change:mode', @menuFastHide
    @home.on "change:focus", @resize
    @home.on 'change:focus', @menuSet
    @home.on 'change:focus', @menuFastHide
    @responsive.on "change:size", @resize
    # init
    @$el.data 'gadget', @model
    @minimize = false
    @resize()

  render:->
    df( "render", @ )
    super
    @$(".menu").collapse({toggle:false})
    @iframe = @$('.content').iframe(@makeSrc()).monitor()
    @menuSet()
    @$(".menu")
      .on("show", @menuOnShow)
      .on("hide", @menuOnHide)
    return @$el

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

  makeSrc:-> """
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

  onRemove:->
    df( "onRemove", @ )
    $.iframeMonitor.remove @$("iframe")[0]
    @remove()
    if @home.get('focus') == @model.id
      next = if @home.get("mode") == "grid" then "" else "list"
      @router.navigate(next,{ trigger: true })
    else
      @parent.replace()

  menuToggle:->
    df( "menuToggle", @ )
    @$(".menu").collapse("toggle")

  menuSet:->
    df( "menuSet", @ )
    if @home.get("focus")?
      @$(".menu .resize"  ).hide()
      @$(".menu .minimize").hide()
      @$(".content").show()
      @$(".title .navbar-inner").removeClass("single")
      @$(".menu .maximize").hide()
    else if @home.get('mode') == "grid"
      @$(".menu .resize"       )[if @minimize then 'show' else 'hide']()
      @$(".menu .minimize"     )[if @minimize then 'hide' else 'show']()
      @$(".content"            )[if @minimize then 'hide' else 'show']()
      @$(".title .navbar-inner")[if @minimize then 'addClass' else 'removeClass']("single")
      @$(".menu .maximize").show()

  menuConfig:->
    df( "menuConfig", @ )
    @$(".menu").collapse("hide")

  menuResize:->
    df( "menuResize", @ )
    @minimize = false
    @menuSet()
    @$(".menu").collapse("hide")

  menuMinimize:->
    df( "menuMinimize", @ )
    @minimize = true
    @menuSet()
    @$(".menu").collapse("hide")

  menuMaximize:->
    df( "menuMaximize", @ )
    @menuFastHide()

  menuDelete:->
    df( "menuDelete", @ )
    @parent.collection.remove @model

  menuFastHide:->
    df( "menuFastHide", @ )
    @$(".menu").height(0).removeClass("in")

  menuOnShow: ->
    df( "menuOnShow", @ )
    menu = @$(".menu")
    menu.height("auto")
    @parent.replace("show")
    menu.height(0)

  menuOnHide: ->
    df( "menuOnHide", @ )
    menu = @$(".menu")
    menu.hide()
    @parent.replace("hide")
    menu.show()
# }}}

