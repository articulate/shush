$(document).ready(function() {
  $note = $("#note")
  $ttl = $("#ttl")

  function decrypt(msg) {
    triplesec.decrypt({
      data: new triplesec.Buffer(msg, "hex"),
      key:  new triplesec.Buffer('top-secret-pw'),
      progress_hook: progressReporter
    }, writeMessage);
  }

  function progressReporter(obj) {
    console.log(obj);
  }

  function writeMessage(err, buff) {
    if (!err) {
      $note.text(buff.toString());
    } else {
      $note.text("Could not decrypt your secrest.")
    }
  }

  $.ajax("/note/" + $note.data('nid'), {contentType: "application/json"})
    .done(function(data) {
      decrypt(data.note);

      if(data.ttl) { $ttl.text("This note will be destroyed in " + data.ttl + " minutes."); }
    }).fail(function(xhr, status, error) {
      window.location = "/read/not_found"
    });

});
