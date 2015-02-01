$(document).ready(function() {
  var $form = $('form#input')
    , $progress = $('#progress')
    , $message = $('#note')
    , $url = $('#url')
    , $when = $('#when')
    , $expireSelects = $("#expire-read, #expire-time")
    , $times = $("#expire-at");

  function toggleTimeSelect(evt) {
    var isTimed = $(this).val() == 'time';
    $times.toggle(isTimed);
  }

  function sendMessage(err, buff) {
    if (!err) {
      var data = $form.serializeObject();
      data.secret = buff.toString('hex');

      $.post($form.attr('action'), data).done(showUrl);
    } else {
      alert("Could not Secrest this Secrest")
    }
  }

  function showUrl(data) {
    var timeText = data.time ? "in #{data.time}" : "when read";

    $url.val(data.url);
    $when.text(timeText)
      .parents().show();
    $form.hide();
  }

  function progressReporter(obj) {
    var what = obj.what
      , i = obj.i
      , total = obj.total;

    console.log(what);
  }

  function encrypt(msg) {
    triplesec.encrypt({
      data:          new triplesec.Buffer(msg),
      key:           new triplesec.Buffer('top-secret-pw'),
      progress_hook: progressReporter
    }, sendMessage);
  }

  $expireSelects.on("click", toggleTimeSelect);

  $form.on('submit', function(evt) {
    evt.preventDefault();
    var msg = $message.val()
    encrypt(msg);
  });

});
