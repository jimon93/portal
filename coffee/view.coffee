GadgetNavItem = Backbone.View.extend {
  tagName: 'li'

  initialize : ->
    _.bindAll( @, 'render' )
    @$el.data("gadget",@model)

  render:->
    @$el.html $("<a/>").text(@model.get 'title').attr('href','#')
    return @
}

GadgetNavs = Backbone.View.extend {
  tagName: 'ul'
  className: 'nav nav-tabs nav-stacked'
  id:'gadgets-nav'

  initialize: ->
    _.bindAll @, 'render', 'hide', 'show','_add','_getItem'
    @collection.on 'reset', @render
    @collection.on 'add', @_add
    #@collection.on 'reset', 'render'
    #@collection.on 'add', '_add'
    @$el.sortable {
      cursor : 'move'
      opacity: 0.9
      axis:'y'
      update:(e,ui)=>
        @$el.children().each (i)-> $(@).data('gadget').set('priority',i)
        @collection.trigger('sorted',@collection)
    }
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
}

GadgetIframe = Backbone.View.extend {
  tagName: 'div'
  className: 'gadget span3'

  initialize : ->
    _.bindAll @, 'render', '_makeSrc'
    @$el.data 'gadget', @model

  render:->
    @$el.children().detach()
    @title = $("<p/>").text(@model.get 'title')
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
}

GadgetIframes = Backbone.View.extend {
  tagName: 'div'
  className: 'row'
  id:'gadgets'

  initialize: ->
    _.bindAll @, 'render', 'hide', 'show','_add','_getItem'
    @collection.on 'reset', @render
    @collection.on 'add', @_add

    @$el.masonry { itemSelector: '.gadget', isAnimated: true }
    setPlace = => @$el.masonry('sortreload')
    $.iframeMonitor.option { callback : setPlace }
    $(window).resize setPlace
    @collection.on 'sorted', setPlace
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
    @$el.append item.el
    item.render()
    @$el.masonry 'option', {isAnimated: false}
    @$el.masonry 'sortreload'
    @$el.masonry 'option', {isAnimated: true}

  _getItem : _.memoize(
    (model)-> new GadgetIframe {model}
    (model)-> model.id
  )
}
