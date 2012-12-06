(($)->
  $.fn.iframe = ( src , options )->
    defaults = {
      win : window
      doc : document
      method : "append" # defaultsを一括で設定できるようにしよう
    }
    opt = $.extend(defaults,options)

    iframe = opt.doc.createElement 'iframe'
    iframe.scrolling = 'no'
    iframe.frameBorder = '0'
    #iframe.height = '0'
    #iframe.className = 'gadget'

    this[opt.method](iframe)
    iWin = iframe.contentWindow
    iDoc = iWin.document

    iDoc.open()
    iDoc.write(src)
    iDoc.close()
    return $(iframe)
)(jQuery)

src = """
<!DOCTYPE html>
<html>
<head>
<script src="/js/jquery-1.8.3.js"></script>
</head>
<body style='background-color:red'>
<h1>hello</h1>
<script>
$(function(){
  //alert(foo);
  var n = Math.floor( Math.random() * 10 );
  for(var i=0;i<n;i++){
    //document.write("<h1>hello</h1>");
  }
});
</script>
</body>
</html>
"""

$ ->
  for i in [0...12]
    n = Math.floor( Math.random() * 200 )
    win = $("#main").iframe(src).addClass("span4 gadget").height(n+50)[0].contentWindow
  $("#main").masonry { itemSelector: ".gadget" }
