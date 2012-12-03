// Generated by CoffeeScript 1.4.0
(function() {

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
      iDoc.open();
      iDoc.write(src);
      iDoc.close;
      return $(iframe);
    };
  })(jQuery);

  window.src = "<!DOCTYPE html>\n<html>\n<body style='background-color:red'>\n<h1>hello</h1>\n<script>\nvar n = Math.floor( Math.random() * 12 );\nconsole.log(n);\nfor(var i=0;i<n;i++){\n  write(\"<h1>hello</h1>\");\n}\n</script>\n</body>\n</html>";

}).call(this);
