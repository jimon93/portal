# iframe 関連 {{{
do ($ = jQuery)->
  # iframe monitor {{{
  class IframeMonitor
    defaults = {
      watch: true
      interval: 100
      callback:->
    }

    constructor:(options = {})->
      @options = $.extend {}, defaults, options
      @iframes = []
      @timerID = null
      @resize() if @options.watch

    add:(iframe)->
      @iframes.push iframe
      resized = @_resetSize iframe
      @options.callback.call @, @iframes if resized
      return this

    start:->
      @resize() if timerID?
      return this

    stop:->
      clearTimeout timerID
      timerID = null
      return this

    resize:->
      clearTimeout timerID if timerID?
      resized = false
      resized = @_resetSize(iframe) or resized for iframe in @iframes
      @options.callback.call @, @iframes if resized
      timerID = setTimeout (=> @resize()) , @options.interval
      return this

    option:(options)->
      @options = $.extend {}, defaults, options
      return this

    _resetSize:(iframe)->
      $iframe = $(iframe)
      oldHeight = $iframe.height()
      if $.browser.msie
        newHeight = iframe.contentWindow.document.documentElement.scrollHeight
      else
        newHeight = iframe.contentWindow.document.documentElement.offsetHeight
      changed = oldHeight != newHeight
      $iframe.height newHeight if changed
      return changed
  $.iframeMonitor = monitor = new IframeMonitor()
  # }}}
  # iframe maker {{{
  $.fn.iframe = do ->
    defaults = {
      win : window
      doc : document
      method : "append"
    }
    # method
    ( src , options = {} )->
      opt = $.extend({},defaults,options)

      iframe = opt.doc.createElement 'iframe'
      iframe.scrolling = 'no'
      iframe.frameBorder = '0'
      iframe.height = '0'

      this[opt.method](iframe)
      iWin = iframe.contentWindow
      iDoc = iWin.document
      iDoc.open()
      iDoc.write(src)
      iDoc.close()

      $iframe = $(iframe)
      $iframe.monitor = ->
        monitor.add iframe
        return $iframe
      return $iframe
  #}}}
#}}}
do ($ = jQuery)->
  # sortreload {{{
  $.Mason::sortreload = (callback)->
    #@reloadItems()
    @$bricks = @_getBricks @element.children()
    @$bricks = @$bricks.get().sort (l,r)->
      lv = $(l).data("priory")
      rv = $(r).data("priory")
      if lv <= rv then (if lv < rv then -1 else 0 ) else 1
    @$bricks = $( @$bricks )
    @_init( callback )
  # }}}
  # src{{{
  makeSrc = (i)-> """
  <!DOCTYPE html>
  <html>
  <head>
  <link rel="stylesheet" href="/css/bootstrap.css">
  <script src="/js/jquery-1.8.3.js"></script>
  </head>
  <body class='alert'>
  <h1>hello</h1>
  <script>
  window.onload = function(){
    var n = Math.floor( Math.random() * 5 );
    for(var i=0;i<n;i++){
      $("body").append("<h1>hello</h1>")
    }
    $("body").on("click",function(){
      $("body").append("<h1>hello</h1>")
    });
  }
  </script>
  </body>
  </html>
  """
  #}}}
  # repeat {{{
  repeat = (end, func)->
    idx = 0
    _main = ->
      setTimeout (-> func(idx); _main() if idx++ < end) ,1
    _main() if idx++ < end
  # }}}
  $ ->
    main = $('#iframes')
    nav  = $('#iframes-nav')

    # event
    main.masonry { itemSelector: '.gadget' }
    window.setPlace = (e)->
      main.masonry('sortreload')
      #main.masonry('reload')
    $.iframeMonitor.option { callback : setPlace }

    nav.sortable {
      cursor : 'move'
      opacity: 0.9
      axis:'y'
      update:(e,ui)->
        nav.children().each (i)-> $(@).data('gadget').data('priory',i)
        setPlace()
    }
    nav.disableSelection()

    # iframeを作る
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


