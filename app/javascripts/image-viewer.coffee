$ = require('jquery')
ipc_renderer = require('electron').ipcRenderer
pather = require('path')

# TODO: do not launch this automatically
ipc_renderer.send('open-jp2', 'hs-2006-01-a-hires_tif')

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
