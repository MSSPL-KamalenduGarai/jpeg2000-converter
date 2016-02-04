// Generated by CoffeeScript 1.10.0
(function() {
  var $, ipc_renderer;

  $ = require('jquery');

  ipc_renderer = require('electron').ipcRenderer;

  $(document).ready(function() {
    $('body').on('click', '.path-to-file,.image-of-file', function(e) {
      ipc_renderer.send('open-image', this.href);
      return e.preventDefault();
    });
    $('body').on('click', '.output-jp2', function(e) {
      var path;
      path = this.innerText;
      ipc_renderer.send('open-jp2', path);
      return e.preventDefault();
    });
    $('#launch-pan-zoom').on('click', function() {
      return $('#pan-zoom-file-select-input').click();
    });
    return $('#pan-zoom-file-select-input').on('change', function(e) {
      var input, path;
      input = $('#pan-zoom-file-select-input');
      path = input[0].files[0].path;
      return ipc_renderer.send('open-jp2', path);
    });
  });

}).call(this);
