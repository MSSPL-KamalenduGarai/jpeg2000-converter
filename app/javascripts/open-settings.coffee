$ = require('jquery')
ipc_renderer = require('electron').ipcRenderer

$(document).ready ->
  $('#settings').on 'click', ->
    ipc_renderer.send('open-settings')
