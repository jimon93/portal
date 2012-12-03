// Generated by CoffeeScript 1.4.0
var src;

(function($) {
  return $.fn.iframe = function(src, options) {
    var defaults, iDoc, iWin, iframe, opt;
    defaults = {
      win: window,
      doc: document,
      method: "replaceWith"
    };
    opt = $.extend(defaults, options);
    iframe = opt.doc.createElement('iframe');
    iframe.scrolling = 'no';
    iframe.frameBorder = '0';
    $(this)[opt.method](iframe);
    iWin = iframe.contentWindow;
    iDoc = iWin.document;
    iWin.hoge = "hoge";
    iDoc.open();
    iDoc.write(src);
    iDoc.close;
    return $(iframe);
  };
})(jQuery);

src = "<!DOCTYPE html>\n  <html>\n  <body style='background-color:red'>\n  <h1>hello</h1>\n  <script>console.log(\"hello\",hoge);</script>\n  </body>\n  </html>";
