JimonPortalRouter = Backbone.Router.extend {
	routes: {
		"gadget/:id" : "gadget"
		""           : "home_grid"
		"home"       : "home_grid"
		"list"       : "home_list"
		"grid"       : "home_grid"
	}

	initialize:(opt)->
		#@home = opt.home
		@[key] = opt[key] for key in ["home"]

	home_list:->
		@home.set("mode","list")
		@home.trigger( "changed:mode", @home )

	home_grid:->
		@home.set("mode","grid")
		@home.trigger( "changed:mode", @home )

	gadget:(id)->
		#console.log "route", "gadget", id
		@home.set("foucs",id,{silent:true})
		@home.unset('mode',{silent:true}) if @home.get('foucs') != @home.previous('foucs')
		@home.set("mode","full")
		@home.trigger( "changed:mode", @home )
}
