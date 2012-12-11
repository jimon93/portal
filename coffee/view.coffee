# Home {{{
Home = Backbone.Model.extend {
  defaults:-> {
  }
} # }}}
# HomeView {{{
HomeView = Backbone.View.extend {
  id: 'hoem'
  className: 'container'

  initialize:(options)->
    # bind
    _.bindAll @

    # field
    @[key] = options[key] for key in ["home","responsive","router"]
    general_opt = {
      responsive : @responsive
      home: @home
      router: @router
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
} # }}}
# HomeSubView {{{
HomeSubView = Backbone.View.extend {
  initialize: (opt)->
    # bind
    _.bindAll @, 'resize'

    # field
    @[key] = opt[key] for key in ["home","responsive","router"]

    # event
    @home.on "change:mode", @resize
    @responsive.on "change:size", @resize

  resize:->
    prev = @span
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
    #console.log "sub resize", prev, next
    @$el.show() if prev == 0
    @$el.removeClass("span#{prev}").addClass("span#{next}")
    @$el.hide() if next == 0
    @span = next
}
# }}}
# HomeViewSwitch {{{
HomeViewSwitch = Backbone.View.extend {
  id: 'home-view-switch'
  className: 'btn-toolbar hidden-phone'

  initialize: (opt)->
    # bind
    _.bindAll @, "onMode"

    # field
    @[key] = opt[key] for key in ["home","router"]

    # event
    @home.on "change:mode", @onMode

  onMode:->
    @$("##{@home.previous('mode')}").removeClass("active")
    @$("##{@home.get('mode')}").addClass("active")
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

  initialize: (opt)->
    # bind
    _.bindAll @, 'render', 'add','getItem'

    #field
    @[key] = opt[key] for key in ["home","router"]

    # event
    @collection.on 'reset', @render
    @collection.on 'add', @add

    # init
    @$el.sortable( @sortable_options() )
    @$el.disableSelection()
    @render()

  render: ->
    @$el.children().detach()
    @collection.each @add

  add:(model)->
    item = @getItem model
    index = @collection.sortedIndex model, (m)->m.get 'priority'
    if index == 0
      @$el.prepend item.render().el
    else
      @$el.children().eq(index-1).after item.render().el

  getItem : _.memoize(
    (model)-> new GadgetNavItem {
      model
      home: @home
      responsive: @responsive
      router: @router
    }
    (model)-> model.id
  )
} # }}}
# GadgetNavsItem {{{
GadgetNavItem = Backbone.View.extend {
  tagName: 'li'

  initialize : (opt)->
    # bind
    _.bindAll( @, 'render', "gadget_full" )

    # field
    @[key] = opt[key] for key in ["home","router","responsive"]
    @$el.data("gadget",@model)

  render:->
    @$el
      .html $("<a/>")
      .text(@model.get 'title')
      .addClass("to-gadget")
      .attr('href',"#gadget/#{@model.id}")
    return @

  gadget_full: (e)->
    #console.log "gadget_full", @model.id
    #@router.navigate( "gadget/#{@model.id}", {trigger:true} )
    @router.navigate("gadget/#{@model.id}",{trigger:true})
    return false
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
      'add'
      'getItem'
      'setPlace'
      'resize'
    )

    # field
    @home = opt.home
    @responsive = opt.responsive
    @$row = @$('.row')

    # event
    @collection.on 'reset', @render
    @collection.on 'add', @add
    @collection.on 'sorted', @setPlace
    @home.on "change:mode", @resize
    @home.on "changed:mode", @setPlace
    @responsive.on "change:size", @resize
    @responsive.on 'changed:size', @setPlace

    # init
    @$row.masonry { itemSelector: '.gadget:visible', isAnimated: true }
    $.iframeMonitor.option { callback : @setPlace }
    @render()
    #@resize()

  render: ->
    @$row.children().detach()
    @collection.each @add

  add:(model)->
    item = @getItem model
    @$row.append item.el
    item.render()
    @setPlace(false)

  # fixElement
  setPlace: (animate = true)->
    #console.info 'setPlace'
    switch @home.get('mode')
      when 'grid'
        @$row.masonry 'option', {isAnimated: false} if !animate
        @$row.masonry('sortreload')
        @$row.masonry 'option', {isAnimated: true}  if !animate
        #@$row.hide().stop().fadeIn()
      when 'full'
        @$row.masonry 'option', {isAnimated: false}
        @$row.masonry('sortreload')
        @$row.masonry 'option', {isAnimated: true}
        #@$row.hide().stop().fadeIn()

  resize:->
    #console.log "main resize"
    prev = @span
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
    @$el.show() if prev == 0
    @$el.removeClass("span#{prev}").addClass("span#{next}")
    @$el.hide() if next == 0
    @span = next

  getItem : _.memoize(
    (model)-> new GadgetIframe {
      model
      responsive: @responsive
      home: @home
    }
    (model)-> model.id
  )
} # }}}
# GadgetIframe {{{
GadgetIframe = Backbone.View.extend {
  tagName: 'div'
  className: 'gadget'

  initialize : (opt)->
    # bind
    _.bindAll @, 'render', '_makeSrc', 'resize'

    # field
    @home = opt.home
    @responsive = opt.responsive

    # event
    @home.on "change:mode", @resize
    @responsive.on "change:size", @resize

    # init
    @$el.data 'gadget', @model
    @resize()

  render:->
    @$el.children().detach()
    @title = $("<p/>")
      .text(@model.get 'title')
      .addClass("alert alert-info title")
      .appendTo @$el
    @iframe = @$el.iframe(@_makeSrc()).monitor()
    return @

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
    #console.log "gadget resize"
    prev = @span
    next = switch @home.get('mode')
      when 'list' then 0
      when 'grid'
        switch @responsive.get('size')
          when 'large', 'desktops' then 3
          when 'tablets' then 4
          when 'phones' then 0
      when 'full'
        switch @home.get('foucs')
          when "#{@model.id}"
            switch @responsive.get('size')
              when 'large', 'desktops' then 9
              when 'tablets','phones' then 12
          else 0
    @$el.show() if prev == 0
    @$el.removeClass("span#{prev}").addClass("span#{next}")
    @$el.hide() if next == 0
    @span = next
}
# }}}
