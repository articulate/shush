$(document).ready(function() {
  $note = $("#note")
  $ttl = $("#ttl")

  $.ajax("/note/" + $note.data('nid'), {contentType: "application/json"})
    .done(function(data) {
      $note.text(data.note);
      $ttl.text("This note will be destroyed " + data.ttl + ".").show();

    }).fail(function(xhr, status, error) {
      window.location = "/read/not_found"
    });

});
