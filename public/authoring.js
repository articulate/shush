$(document).ready(function() {
  var $form = $('form#input')
  var $save = $('#save')
    , $message = $('#note')
    , $readSelect = $("#expire-read")
    , $timeSelect = $("#expire-time")
    , $times = $("#expire-at");

  function toggleTimeSelect(evt) {
    $times.toggle($timeSelect.is(":checked"));
  }

  function sendMessage(err, buff) {
    if (!err) {
      $message.val(buff.toString('hex'));
      $form.submit();
    } else {
      $message.val("Could not secrest");
    }
  }

  function progressReporter(obj) {
    console.log(obj);
  }

  function encrypt(msg) {
    triplesec.encrypt({
      data:          new triplesec.Buffer(msg),
      key:           new triplesec.Buffer('top-secret-pw'),
      progress_hook: progressReporter
    }, sendMessage);
  }

  $readSelect.on("click", toggleTimeSelect);
  $timeSelect.on("click", toggleTimeSelect);

  $save.on('click', function(evt) {
    evt.preventDefault();
    var msg = $message.val()

    $message.val("Secresting...");
    encrypt(msg);
  });

});
