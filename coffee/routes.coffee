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
    @home.unset("foucs",{silent:true})
    @home.set("mode","list")

  home_grid:->
    @home.unset("foucs",{silent:true})
    @home.set("mode","grid")

  gadget:(id)->
    #console.log "route", "gadget", id
    id = parseInt(id)
    @home.set("foucs",id,{silent:true})
    #console.log "route gadget", @home.get('foucs') , @home.previous('foucs')
    @home.unset('mode',{silent:true}) if @home.get('foucs') != @home.previous('foucs')
    @home.set("mode","full")
