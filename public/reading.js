$(document).ready(function() {
  var mtype;

  $title = $("#title")
  $note = $("#note")
  $image = $("#display-secret-image")
  $ttl = $("#ttl")
  $info = $(".info")

  $.ajax("/note/" + $note.data('nid'), {contentType: "application/json"})
    .done(function(data) {
      // Undestroyed "legacy" notes without a type should be considered text
      if (!data.type || data.type == "text") {
        $image.hide();
        $title.text("Here's your note");
        $note.text(data.note);
        $note.show();
        mtype = "note";
      } else {
        $note.hide();
        $title.text("Here's your image");
        $image.attr("src", data.note);
        $image.show();
        mtype = "image";
      }

      $ttl.text("This "
        + mtype
        + " will be destroyed "
        + data.ttl
        + ".").show();

      $info.text("If it's important, save this "
        + mtype
        + " somewhere secure. Once the "
        + mtype
        + " expires, we can't retrieve it for you.")
    }).fail(function(xhr, status, error) {
      window.location = "/read/not_found"
    });
});
