(($)->
  $.fn.iframe = ( src , options )->
    defaults = {
      win : window
      doc : document
      method : "replaceWith"
    }
    opt = $.extend(defaults,options)

    iframe = opt.doc.createElement 'iframe'
    iframe.scrolling = 'no'
    iframe.frameBorder = '0'
    #iframe.height = '0'
    #iframe.className = 'gadget'

    $(@)[opt.method](iframe)
    iWin = iframe.contentWindow
    iDoc = iWin.document

    iWin.hoge = "hoge"
    iDoc.open()
    iDoc.write(src)
    iDoc.close
    return $(iframe)

)(jQuery)

# jQueryメソッドでいいんじゃないかな…
#appendIframe = ( src, target, method = 'append', win = window, doc = document )->
#  iframe = doc.createElement 'iframe'
#  iframe.scrolling = 'no'
#  iframe.frameBorder = '0'
#  #iframe.height = '0'
#  iframe.className = 'gadget'
#
#  target[method](iframe)
#  iWin = iframe.contentWindow
#  iDoc = iWin.document
#
#  iWin.hoge = "hoge"
#  iDoc.open()
#  iDoc.write(src)
#  iDoc.close
#  return iframe

src = """
<!DOCTYPE html>
  <html>
  <body style='background-color:red'>
  <h1>hello</h1>
  <script>console.log("hello",hoge);</script>
  </body>
  </html>
"""
