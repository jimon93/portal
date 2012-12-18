class JimonPortalRouter extends Backbone.Router
  routes: {
    ""           : "home"
    "gadget/:id" : "gadget"
    "market"     : "market"
  }

  trigger:(name, args...)->
    @prevTriggerName = name
    @prevTriggerArgs = args
    super

  refire:(name, callback, context = @)->
    callback.apply( context, @prevTriggerArgs ) if name == @prevTriggerName

  home:->
    info "router", "home"

  gadget:(id)->
    info "route", "gadget", "id=#{id}"
    id = parseInt(id)

  market:->
    info "router", "market"
