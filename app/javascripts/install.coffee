$ = require('jquery')
shell = require('electron').shell
ipc_renderer = require('electron').ipcRenderer
which = require('which')

check_install = ->
  console.log 'gets here'
  which 'kdu_compres', (err, path) ->
    if path?
      $('#retry-launch-section').show()
      clearInterval(check_interval)

check_interval = setInterval ->
  check_install()
, 1000


$(document).ready ->
  $('#open-install').on 'click', ->
    shell.openExternal('http://kakadusoftware.com/downloads/')

  $('#retry-launch').on 'click', ->
    ipc_renderer.send('retry-launch')
