$ = require('jquery')
electron = require('electron')
settings = electron.remote.getCurrentWindow().settings
ipc_renderer = require('electron').ipcRenderer

insert_output_dir = ->
  $('#output_dir').html(settings.get('output_dir'))

$(document).ready ->
  insert_output_dir()

  $('#change-output-directory').on 'click', ->
    $('#file-select-input').click()

  $('#file-select-input').on 'change', (e) ->
    files = $('#file-select-input')[0].files
    path = files[0].path
    settings.set('output_dir', path)
    insert_output_dir()
    ipc_renderer.send('open-mainwindow-if-not')
