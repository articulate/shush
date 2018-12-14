$(document).ready(function() {
  $notifySelect = $("#notify")
  $email = $("#email")
  $readSelect = $("#expire-read")
  $timeSelect = $("#expire-time")
  $times = $(".select-wrapper")
  $flash = $("#flash")
  $message = $("#message")
  $secretImage = $("#secret-image")
  $messageTypes = $("input[name=secret-type]") // Radio button group
  $optionsLabel = $("#options-label")

  function toggleTimeSelect(evt) {
    $times.toggle($timeSelect.is(":checked"));
  }

  function toggleEmail(evt) {
    $email.toggle($notifySelect.is(":checked"));
  }

  function toggleMessageType(evt) {
    displayMessageType($(this).val());
  }

  function displayMessageType(type) {
    if (type == "image") {
      $message.hide();
      // Required for file input styling, which uses the :valid pseudo-class
      $("#secret-image input[name=secret-image]").prop("required", true);
      $secretImage.show();
    } else {
      $secretImage.hide();
      // Remove attribute from this hidden element so the form will validate 
      $("#secret-image input[name=secret-image]").prop("required", false);
      $message.show();
    }
  }

  $readSelect.on("click", toggleTimeSelect);
  $timeSelect.on("click", toggleTimeSelect);
  $notifySelect.on("click", toggleEmail);
  $messageTypes.on("click", toggleMessageType);

  setTimeout(function() {
    $flash.hide('slow');
  }, 2000);

  $("#note").focus();
  $("#type-message").prop("checked", true); // Default on load/reload
});
