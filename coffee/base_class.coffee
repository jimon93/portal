class BaseModel extends Backbone.Model

class BaseView extends Backbone.View
  initialize:->
    _.bindAll( @
      "routes"
      "render"
      "add"
      "resize"
      "container"
      "template"
      "compiled"
    )
    # field
    @children = {}

  routes:(route)->
    route.replace(/^route:/,'')

  render:->
    df( "render(super)", @ )
    if @templateSelector?
    then @$el.html @template( @model?.toJSON() or @collection?.toJSON() )
    else @$el.html ''
    @collection.each( @add ) if @collection? and @makeChildView?
    return @

  remove:->
    @$el.detach()
    @stopListening()
    return @

  add:(model)->
    df( "add(super)", @ )
    item = @makeChildView( model )
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
    df( "resize(super)", @ )
    prev = @span
    @$el.show() if prev == 0
    @$el.removeClass("span#{prev}").addClass("span#{next}")
    @$el.hide() if next == 0
    # Popのアニメーションを入れるならここに
    @span = next

  container:->
    df( "container(super)", @ )
    # リファクタリングすべき
    if @containerSelector?
    then @$(@containerSelector)
    else @$el

  template:->
    df( "template(super)", @ )
    @compiled(@templateSelector).apply @, arguments

  compiled: _.memoize (selector)->
    if selector?
    then _.template $(selector).html()
    else -> ''

  getValue: (val)->
    if _.isFunction val
    then val()
    else val

