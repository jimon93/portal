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

    iDoc.open()
    iDoc.write(src)
    iDoc.close
    return $(iframe)

)(jQuery)

window.src = """
<!DOCTYPE html>
<html>
<body style='background-color:red'>
<h1>hello</h1>
<script>
var n = Math.floor( Math.random() * 12 );
console.log(n);
for(var i=0;i<n;i++){
  write("<h1>hello</h1>");
}
</script>
</body>
</html>
"""
