class BaseModel extends Backbone.Model

class BaseView extends Backbone.View
  initialize:->
    _.bindAll( @ )
    @children = {}

  routes:(route)->
    route.replace(/^route:/,'')

  render:->
    @$el.html @template( @model?.toJSON() or @collection?.toJSON() or {} )
    @appendChildView()
    @deligateEvent()
    @collection.each( @add ) if @collection? and @getChildView?
    @rendered()
    return @

  appendChildView:->
  deligateEvent:->
  rendered:->

  remove:->
    #child.remove() for cid, child of @children
    if @collection? and @getChildView?
      @collection.each (model)=> @getChildView(model).remove()
    @$el.detach()
    @stopListening()
    return @

  rewrite:->
    #child.remove() for cid, child of @children
    @render()

  add:(model)->
    item = @getChildView( model )
    if @collection?.comparator?
      index = @collection.sortedIndex( model, @collection.comparator )
      switch index
        when 0 then @container().prepend( item.el )
        else @container().children().eq(index-1).after( item.el )
    else
      @container().append( item.el )
    item.render()
    @children[item.cid] = item
    return item

  resize:(next)->
    prev = @span
    @$el.show() if prev == 0
    @$el.removeClass("span#{prev}").addClass("span#{next}")
    @$el.hide() if next == 0
    # Popのアニメーションを入れるならここに
    @span = next

  container:->
    # リファクタリングすべき
    if @containerSelector?
    then @$(@containerSelector)
    else @$el

  template:->
    compiled = if @templateString?
      @compiled( @templateString, "string" )
    else if @templateSelector?
      @compiled( @templateSelector, "selector" )
    else
      @compiled( "", "string" )
    compiled.apply(@, arguments)

  compiled: _.memoize (string, type)->
    switch type
      when "string"   then _.template string
      when "selector" then _.template $(string).html()

  getValue: (val)->
    if _.isFunction val
    then val()
    else val

