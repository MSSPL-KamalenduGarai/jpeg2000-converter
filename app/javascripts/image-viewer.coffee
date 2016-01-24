$ = require('jquery')
ipc_renderer = require('electron').ipcRenderer
pather = require('path')

$(document).ready ->
  $('body').on 'click', '.path-to-file,.image-of-file', (e) ->
    ipc_renderer.send('open-image', @.href)
    e.preventDefault()
    # open the image in another window

  $('body').on 'click', '.output-jp2', (e) ->
    path = @.innerText
    extname = pather.extname(path)
    basename = pather.basename(path, extname)
    ipc_renderer.send('open-jp2', basename)
    e.preventDefault()
