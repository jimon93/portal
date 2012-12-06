# iframe {{{
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
      #@options.callback.call @, @iframes if resized
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
      method : "append"
    }
    # method
    ( src , options = {} )->
      opt = $.extend({},defaults,options)
      doc = opt.win.document

      iframe = doc.createElement 'iframe'
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

