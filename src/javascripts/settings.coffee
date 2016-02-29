$ = require('jquery')
electron = require('electron')
current_window = electron.remote.getCurrentWindow()
settings = current_window.settings
ipc_renderer = require('electron').ipcRenderer
packagejson =  require('../../package.json')

insert_output_dir = ->
  $('#output_dir').html(settings.get('output_dir'))

check_jp2_binary = ->
  $("##{settings.get('jp2_binary')}").prop('checked', true)

insert_version = ->
  $('#version').html(packagejson.version)

$(document).ready ->
  insert_version()
  insert_output_dir()
  check_jp2_binary()

  $('#change-output-directory').on 'click', ->
    $('#file-select-input').click()

  $('#file-select-input').on 'change', (e) ->
    files = $('#file-select-input')[0].files
    path = files[0].path
    settings.set('output_dir', path)
    insert_output_dir()
    ipc_renderer.send('open-mainwindow-if-not')

  $('#jp2_binary').on 'change', (e) ->
    settings.set 'jp2_binary', e.target.id

  $('#close_window').on 'click', ->
    current_window.close()
