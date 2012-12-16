class HomeBaseView extends BaseView

# HomeView {{{
class HomeView extends HomeBaseView
  containerSelector: ">.row"

  initialize: ->
    # field
    @subView = new HomeSubView {
      #el: @$(".sub")
      collection: @collection
    }
    @gadgetIframes = new GadgetIframes {
      collection: @collection
      #el: @$('#gadgets')
    }
    # init
    @render()

  render:->
    @$el.append("<div class='row' />")
    @container().append @subView.render()
    @container().append @gadgetIframes.render()
# }}}
# HomeSubView {{{
class HomeSubView extends HomeBaseView
  className: "sub"

  initialize: ->
    super
    # field
    @homeViewSwitch = new HomeViewSwitch()
    @gadgetNavs = new GadgetNavs { collection: @collection }
    # event
    @home.on       "change:mode", @resize
    @responsive.on "change:size", @resize

  render:->
    @$el.append @homeViewSwitch.render()
    @$el.append @gadgetNavs.render()
    return @$el

  resize:->
    next = switch @home.get('mode')
      when 'list' then 12
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 12
      when 'full'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets', 'phones' then 0
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
    super
    # bind
    _.bindAll @, "onMode"
    # event
    @home.on "change:mode", @onMode

  onMode:->
    @$("##{@home.previous('mode')}").removeClass("active")
    @$("##{@home.get('mode')}").addClass("active")
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
    super
    # bind
    _.bindAll( @, 'active' )
    # field
    @$el.data("gadget",@model)
    # event
    @home.on("change:mode",@active)
    @model.on "remove", => @remove()
    # init
    @active()

  active:->
    foucs = @home.get("foucs")
    #console.log "active", @model.id, foucs == @model.id
    @$el[if foucs? and foucs == @model.id then "addClass" else "removeClass"]("active")
# }}}
# GadgetIframes {{{
class GadgetIframes extends HomeBaseView
  id: "gadgets"
  className: "main"
  containerSelector:".row"

  initialize: ->
    super
    # bind
    _.bindAll( @, 'replace')
    # event
    @collection.on 'reset', @render
    @collection.on 'add', @add
    @collection.on 'sorted', _.bind(@replace,@,"sorted")
    @home.on "change:mode", @resize
    @home.on "changed:mode", _.bind(@replace,@,"changed:mode")
    @responsive.on "change:size", @resize
    @responsive.on 'changed:size', _.bind(@replace,@,"changed:size")
    # init
    $.iframeMonitor.option { callback : _.bind(@replace,@,"iframe") }

  render: ->
    super
    @$el.append("<div class='row' />")
    @collection.each @add
    return @$el

  add:(model)->
    child = super
    menu = child.$(".menu")
    menu.on 'show', _.bind( @menuOnShow, @, menu )
    menu.on 'hide', _.bind( @menuOnHide, @, menu )
    @replace("add",false)

  makeChildView: _.memoize(
    (model)-> new GadgetIframe { model, parent:@ }
    (model)-> model.id
  )

  replace: (name,animate = true)->
    #console.info "replace", name
    _container = @container()
    if not _container.is(".masonry")
      _container.masonry { itemSelector: '.gadget:visible', isAnimated: true }
    switch @home.get('mode')
      when 'grid'
        _container.masonry 'option', {isAnimated: false} if !animate
        _container.masonry('sortreload')
        _container.masonry 'option', {isAnimated: true}  if !animate
      when 'full'
        _container.masonry 'option', {isAnimated: false}
        _container.masonry('sortreload')
        _container.masonry 'option', {isAnimated: true}

  resize:->
    next = switch @home.get('mode')
      when 'list' then 0
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 9
          when 'tablets' then 8
          when 'phones' then 0
      when 'full'
        switch @responsive.get('size')
          when 'large', 'desktops' then 9
          when 'tablets', 'phones' then 12
    super next

  menuOnShow: (menu)->
    menu.height("auto")
    @replace("show")
    menu.height("0")

  menuOnHide: (menu)->
    menu.hide()
    @replace("hide")
    menu.show()
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
    )
    # field
    @parent = @options.parent
    # event
    @model.on "remove", @onRemove
    @home.on "change:mode", @resize
    @home.on 'change:mode', @menuSet
    @home.on 'change:mode', @menuFastHide
    @responsive.on "change:size", @resize
    # init
    @$el.data 'gadget', @model
    @minimize = false
    @resize()

  render:->
    super
    @$(".menu").collapse({toggle:false})
    @iframe = @$('.content').iframe(@makeSrc()).monitor()
    @menuSet()
    return @

  resize:->
    next = switch @home.get('mode')
      when 'list' then 0
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 0
      when 'full'
        switch @home.get('foucs')
          when @model.id
            switch @responsive.get('size')
              when 'large', 'desktops' then 9
              when 'tablets','phones' then 12
          else 0
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
    $.iframeMonitor.remove @$("iframe")[0]
    @remove()
    @parent.replace()

  menuToggle:->
    @$(".menu").collapse("toggle")

  menuSet:->
    switch @home.get('mode')
      when 'grid'
        @$(".menu .resize"       )[if @minimize then 'show' else 'hide']()
        @$(".menu .minimize"     )[if @minimize then 'hide' else 'show']()
        @$(".content"            )[if @minimize then 'hide' else 'show']()
        @$(".title .navbar-inner")[if @minimize then 'addClass' else 'removeClass']("single")
        @$(".menu .maximize").show()
      when 'full'
        @$(".menu .resize"  ).hide()
        @$(".menu .minimize").hide()
        @$(".content").show()
        @$(".title .navbar-inner").removeClass("single")
        @$(".menu .maximize").hide()

  menuConfig:->
    console.log "menu config"
    @$(".menu").collapse("hide")

  menuResize:->
    @minimize = false
    @menuSet()
    @$(".menu").collapse("hide")

  menuMinimize:->
    @minimize = true
    @menuSet()
    @$(".menu").collapse("hide")

  menuMaximize:->
    @menuFastHide()

  menuDelete:->
    @parent.collection.remove @model

  menuFastHide:->
    @$(".menu").height(0).removeClass("in")
# }}}

