$(document).ready(function() {
  $notifySelect = $("#notify")
  $email = $("#email")
  $readSelect = $("#expire-read")
  $timeSelect = $("#expire-time")
  $times = $("#expire-at")
  $flash = $("#flash")

  function toggleTimeSelect(evt) {
    $times.toggle($timeSelect.is(":checked"));
  }

  function toggleEmail(evt) {
    $email.toggle($notifySelect.is(":checked"));
  }

  $readSelect.on("click", toggleTimeSelect);
  $timeSelect.on("click", toggleTimeSelect);
  $notifySelect.on("click", toggleEmail);

  setTimeout(function() {
    $flash.hide('slow');
  }, 2000);

  $("#note").focus();
});
