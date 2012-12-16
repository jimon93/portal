do ($ = jQuery)->
  $ ->
    # template
    _.templateSettings = {
      evaluate    : /\[\[([\s\S]+?)\]\]/g,
      interpolate : /\[\[=([\s\S]+?)\]\]/g,
      escape      : /\[\[-([\s\S]+?)\]\]/g
    }
    # models & collections
    responsive = new Responsive()
    gadgets = new Gadgets()
    home = new BaseModel()
    # router
    router = new JimonPortalRouter {
      home
    }
    # views
    BaseView::responsive = responsive
    HomeBaseView::home = home
    HomeBaseView::router = router
    window.homeView = new HomeView {
      collection: gadgets
      el: $("#home")
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
