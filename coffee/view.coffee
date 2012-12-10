# Home {{{
Home= Backbone.Model.extend {
  defaults:-> {
    #mode: 'grid'
    $root: $("#home")
  }
} # }}}

# HomeView {{{
HomeView = Backbone.View.extend {
  id: 'hoem'
  className: 'container'

  initialize:(options)->
    # bind
    _.bindAll @, 'spanChange'

    # field
    @home = new Home { root: @$el }
    @responsive = options.responsive
    general_opt = {
      responsive : @responsive
      home: @home
    }
    @subView = new HomeSubView $.extend {}, general_opt, {
      el: @$(".sub")
    }
    @homeViewSwitch = new HomeViewSwitch $.extend {}, general_opt, {
      el: @$("#home-view-switch")
    }
    @gadgetNavs = new GadgetNavs $.extend {}, general_opt, {
      collection: @collection
      el: @$('#gadgets-nav')
    }
    @gadgetIframes = new GadgetIframes $.extend {}, general_opt, {
      collection: @collection
      el: @$('#gadgets')
    }

    # event
    @home.on 'change:mode', @spanChange
    @responsive.on 'change:size', @spanChange

    # init
    @spanChange()

  # mode と sub/main-span がだぶってる
  spanChange:->
    #console.log "spanChange", @home.get('mode'),@responsive.get 'size'
    switch @home.get('mode')
      when 'list'
        @home.set 'sub-span', 12
        @home.set 'main-span',0
      when 'grid'
        switch @responsive.get 'size'
          when 'large', 'desktops'
            @home.set 'sub-span'    , 3
            @home.set 'main-span'   , 9
          when 'tablets'
            @home.set 'sub-span'    , 4
            @home.set 'main-span'   , 8
          when 'phones'
            @home.set 'sub-span', 12
            @home.set 'main-span',0
      when 'full'
        @home.set 'sub-span'    , 0
        @home.set 'main-span'   , 12
} # }}}

# HomeSubView {{{
HomeSubView = Backbone.View.extend {
  initialize: (opt)->
    # bind
    _.bindAll @, 'resize'

    # field
    @home or= opt.home
    @spanType = 'sub-span'

    # event
    @home.on "change:#{@spanType}", @resize

    # init
    #@resize()

  resize:->
    now = @home.get @spanType
    prev= @home.previous @spanType
    #console.log "sub resize", now, prev
    if prev == 0
      @$el.show()
    else
      @$el.removeClass("span#{prev}")
    if now == 0
      @$el.hide()
    else
      @$el.addClass("span#{now}")
}
# }}}

# HomeViewSwitch {{{
HomeViewSwitch = Backbone.View.extend {
  id: 'home-view-switch'
  className: 'btn-toolbar hidden-phone'

  events:{
    'click #list': 'listView'
    'click #grid': 'gridView'
  }

  initialize: (opt)->
    # bind
    _.bindAll @, 'listView', 'gridView'

    # field
    @home = opt.home

    # init
    @$("#grid").addClass('active')
    @gridView()

  listView:->
    @home.set( 'mode', 'list' )

  gridView:->
    @home.set( 'mode', 'grid' )
} # }}}

# GadgetNavs {{{
GadgetNavs = Backbone.View.extend {
  id:'gadgets-nav'
  className: 'nav nav-tabs nav-stacked'
  tagName: 'ul'

  sortable_options : -> {
    cursor : 'move'
    opacity: 0.9
    axis:'y'
    update:(e,ui)=>
      @$el.children().each (i)-> $(@).data('gadget').set('priority',i)
      @collection.trigger('sorted',@collection)
  }


  initialize: ->
    # bind
    _.bindAll @, 'render', 'hide', 'show','_add','_getItem'

    # event
    @collection.on 'reset', @render
    @collection.on 'add', @_add

    # init
    @$el.sortable( @sortable_options() )
    @$el.disableSelection()
    @render()

  render: ->
    @$el.children().detach()
    @collection.each @_add

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  _add:(model)->
    item = @_getItem model
    index = @collection.sortedIndex model, (m)->m.get 'priority'
    if index == 0
      @$el.prepend item.render().el
    else
      @$el.children().eq(index-1).after item.render().el

  _getItem : _.memoize(
    (model)-> new GadgetNavItem {model}
    (model)-> model.id
  )
} # }}}

# GadgetNavsItem {{{
GadgetNavItem = Backbone.View.extend {
  tagName: 'li'

  initialize : ->
    _.bindAll( @, 'render' )
    @$el.data("gadget",@model)

  render:->
    @$el.html $("<a/>").text(@model.get 'title').attr('href',"/gadget/#{@model.id}")
    return @
} # }}}

# GadgetIframes {{{
GadgetIframes = Backbone.View.extend {
  tagName: 'div'
  className: 'row'
  id:'gadgets'

  initialize: (opt)->
    # bind
    _.bindAll( @
      'render'
      '_add'
      '_getItem'
      '_setPlace'
      'resize'
    )

    # field
    @home = opt.home
    @responsive = opt.responsive
    @$row = @$('.row')
    @spanType = 'main-span'

    # event
    @collection.on 'reset', @render
    @collection.on 'add', @_add
    @collection.on 'sorted', @_setPlace
    @home.on "change:#{@spanType}", @resize
    @responsive.on 'change:size', =>
      now = @responsive.get 'size'
      prev = @responsive.previous 'size'
      @_setPlace() if now == 'desktops' and prev == 'large' or now == 'large' and prev == 'desktops'
    #@home.on 'change:mode', @_setPlace

    # init
    @$row.masonry { itemSelector: '.gadget', isAnimated: true }
    $.iframeMonitor.option { callback : @_setPlace }
    @render()

  render: ->
    @$row.children().detach()
    @collection.each @_add

  _add:(model)->
    item = @_getItem model
    @$row.append item.el
    item.render()
    @$row.masonry 'option', {isAnimated: false}
    @$row.masonry 'sortreload'
    @$row.masonry 'option', {isAnimated: true}

  _getItem : _.memoize(
    (model)-> new GadgetIframe {
      model
      responsive: @responsive
      home: @home
    }
    (model)-> model.id
  )

  _setPlace: ->
    #console.info 'setPlace'
    @$row.masonry('sortreload')

  resize:->
    now = @home.get @spanType
    prev= @home.previous @spanType
    #console.log "main resize", now, prev
    if prev == 0
      @$el.show()
    else
      @$el.removeClass("span#{prev}")
    if now == 0
      @$el.hide()
    else
      @$el.addClass("span#{now}")
      if now == 9
        @home.set 'gadget-span' , 3
      else if now == 8
        @home.set 'gadget-span' , 4
      else if now == 12
        @home.set 'gadget-span' , 12
      @$row.masonry('sortreload')

} # }}}

# GadgetIframe {{{
GadgetIframe = Backbone.View.extend {
  tagName: 'div'
  className: 'gadget'

  initialize : (opt)->
    # bind
    _.bindAll @, 'render', '_makeSrc', '_spanChange', 'resize'

    # field
    @home = opt.home
    @responsive = opt.responsive
    @spanType = 'gadget-span'

    # event
    @home.on "change:#{@spanType}", @resize

    # init
    @$el.data 'gadget', @model
    #@_spanChange()
    @resize()

  render:->
    @$el.children().detach()
    @title = $("<p/>")
      .text(@model.get 'title')
      .addClass("alert alert-info title")
      .appendTo @$el
    @iframe = @$el.iframe(@_makeSrc()).monitor()
    return @

  _spanChange: ->
    ###
    @$el
      .removeClass("span#{@home.previous('gadget-span')}")
      .addClass("span#{@home.get("gadget-span")}")
    ###

  _makeSrc:-> """
  <!DOCTYPE html>
  <html>
  <head>
  <link rel="stylesheet" href="/css/bootstrap.css">
  <link rel="stylesheet" href="/css/bootstrap-responsive.css">
  <style> body { background-color:#FCF8E3; } </style>
  <script src="/js/jquery-1.8.3.js"></script>
  </head>
  <body>
  #{@model.get 'content'}
  </body>
  </html>
  """

  resize:->
    now = @home.get @spanType
    prev= @home.previous @spanType
    #console.log "gadget resize", now, prev
    if prev == 0
      @$el.show()
    else
      @$el.removeClass("span#{prev}")
    if now == 0
      @$el.hide()
    else
      @$el.addClass("span#{now}")
}
# }}}
