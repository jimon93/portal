class JimonPortalRouter extends Backbone.Router
  routes: {
    "gadget/:id" : "gadget"
    ""           : "home_grid"
    "home"       : "home_grid"
    "list"       : "home_list"
    "grid"       : "home_grid"
  }

  initialize:(opt)->
    @[key] = opt[key] for key in ["home"]

  home_list:->
    info "router", "home/list"
    @home.unset("focus",{silent:true})
    @home.unset("mode",{silent:true})
    @home.set("mode","list")

  home_grid:->
    info "router", "home/grid"
    @home.unset("focus",{silent:true})
    @home.unset("mode",{silent:true})
    @home.set("mode","grid")

  gadget:(id)->
    info "route", "gadget", "id=#{id}"
    id = parseInt(id)
    @home.set("focus",id)
