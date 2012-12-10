JimonPortalRouter = Backbone.Router.extend {
	routes: {
		"gadget/:id": "gadget"
		"": "home"
		"home": "home"
	}

	initialize:(opt)->
		@homeView = opt.homeView

	home:->
		console.log "home"
		@homeView.$el.show()

	gadget:(id)->
		console.log "gadget", id
		@homeView.$el.hide()
}
