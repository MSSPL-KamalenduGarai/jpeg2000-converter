$ = require('jquery')
ipc_renderer = require('electron').ipcRenderer

$(document).ready ->
  $('body').on 'click', '.path-to-file,.image-of-file', (e) ->
    ipc_renderer.send('open-image', @.href)
    e.preventDefault()
    # open the image in another window
