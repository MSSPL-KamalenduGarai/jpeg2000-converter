$ = require('jquery')
shell = require('electron').shell
ipc_renderer = require('electron').ipcRenderer
which = require('which')
check_interval = undefined

check_install = ->
  which 'kdu_compress', (err, path) ->
    if path?
      $('#kdu_compress-polling').hide()
      $('#retry-launch-section').show()
      clearInterval(check_interval)

$(document).ready ->
  $('#open-install').on 'click', ->
    shell.openExternal('http://kakadusoftware.com/downloads/')
    $('#kdu_compress-polling').show()
    check_interval = setInterval ->
      check_install()
    , 1000

  $('#retry-launch').on 'click', ->
    ipc_renderer.send('retry-launch')
