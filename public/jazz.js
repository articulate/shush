$(document).ready(function() {
  $readSelect = $('#expire-read')
  $timeSelect = $('#expire-time')
  $times = $('#expire-at')

  function toggleTimeSelect(evt) {
    $times.toggle($timeSelect.is(':checked'));
  }

  $readSelect.on('click', toggleTimeSelect);
  $timeSelect.on('click', toggleTimeSelect);

});
