$(document).ready(function() {
  var clipboard = new Clipboard('.copy');
  var button = $(".copy");

  clipboard.on('success', function(e) {
    button.val("Copied!");
  });

  clipboard.on('error', function(e) {
    alert("Whoops! Your browser may not support copying to clipbard.");
  });
});
