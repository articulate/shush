$(document).ready(function() {
  var clipboard = new Clipboard('.btn');
  var btn = $(".btn")

  clipboard.on('success', function(e) {
    btn.text("Copied!");
  });

  clipboard.on('error', function(e) {
    alert("Whoops! Your browser may not support copying to clipbard.");
  });
});
