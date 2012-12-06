do ($ = jQuery)->
  $ ->
    main = $('#gadgets')
    nav  = $('#gadgets-nav')

    # event
    ###
    ###

    # iframe
    ###
    repeat 12, (i)->
      n = Math.floor( Math.random() * 200 )
      gadget = $("<div / >").addClass("gadget span3").appendTo main
      gadget.data "priory", i
      title  = $("<p />").text("Title #{i}").addClass("alert alert-info title").appendTo gadget
      navli = $("<li />").appendTo nav
      $("<a href='#' />").text("Title #{i}").appendTo navli
      navli.data("gadget",gadget)
      navli.hover(
        -> title.removeClass("alert-info").addClass("alert-error")
        -> title.addClass("alert-info").removeClass("alert-error")
      )
      iframe = gadget.iframe(makeSrc(i)).monitor()[0]
      gadget.data "iframe", $(iframe)
      gadget.draggable {
        start : (e,ui)-> gadget.css("z-index",1)
        stop : (e,ui)-> gadget.css("z-index",0)
      }
    ###

    $.getJSON('/data.json').then (data)->
      window.gadgets = new Gadgets()
      window.gadget_nav = new GadgetNavs { collection: gadgets, el: nav }
      window.gadget_ifm = new GadgetIframes { collection: gadgets, el: main }
      repeat data.gadgets, (gadget)-> gadgets.add gadget
