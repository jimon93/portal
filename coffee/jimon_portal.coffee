debug = true
do ($ = jQuery)->
  $ ->
    # template
    _.templateSettings = {
      evaluate    : /\[\[([\s\S]+?)\]\]/g
      interpolate : /\[\[=([\s\S]+?)\]\]/g
      escape      : /\[\[-([\s\S]+?)\]\]/g
    }
    # models & collections
    window.responsive = new Responsive()
    window.gadgets = new Gadgets()
    window.home = new BaseModel {
      mode: "grid"
    }
    # router
    window.router = new JimonPortalRouter {
      home
    }
    # views
    BaseView::responsive = responsive
    HomeBaseView::home = home
    HomeBaseView::router = router
    window.homeView = new HomeView {
      collection: gadgets
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
      #repeat data.gadgets, (gadget)-> gadgets.add gadget
      gadgets.add data.gadgets
