do ($ = jQuery)->
  $ ->
    responsive = new Responsive()
    gadgets = new Gadgets()
    router = new JimonPortalRouter {
      homeView : new HomeView {
        collection: gadgets
        el: $("#home")
        responsive: responsive
      }
    }
    #Backbone.history.start()
    Backbone.history.start {pushState:true}
    $.getJSON('/data.json').then (data)->
      repeat data.gadgets, (gadget)-> gadgets.add gadget
