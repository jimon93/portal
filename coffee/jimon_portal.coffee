do ($ = jQuery)->
  $ ->
    # models & collections
    responsive = new Responsive()
    gadgets = new Gadgets()
    home = new Home()
    # router
    router = new JimonPortalRouter {
      home
    }
    # views
    homeView = new HomeView {
      collection: gadgets
      el: $("#home")
      home
      responsive
      router
    }
    #Backbone.history.start()
    Backbone.history.start {
      pushState: true
      hashChange: true
    }

    $("html,body").on "click", "a", ->
      next = $(this).attr('href')
      router.navigate(next,{trigger:true}) if next?
      return false

    $.getJSON('/data.json').then (data)->
      repeat data.gadgets, (gadget)-> gadgets.add gadget
