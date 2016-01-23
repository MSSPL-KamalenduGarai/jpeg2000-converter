$ = require('jquery')
hbs_render = require("#{__dirname}/../javascripts/hbs_render")

handle_files = (files) ->
  for file in files
    line = hbs_render('file_row', {path: file.path})

    $('#container').append(line)

$(document).ready ->
  $(document).on 'dragover,drop', (e) ->
    e.preventDefault()
    return false

  # http://stackoverflow.com/questions/21339924/drop-event-not-firing-in-chrome
  $('#dropzone').on 'drop', (e) ->
    e.preventDefault()
    console.log 'dropped'
    files = e.originalEvent.dataTransfer.files
    handle_files(files)

  $('#dropzone').on 'dragover', (e) ->
    e.preventDefault()
    console.log 'dragover'
    return false

  $('#dropzone').on 'dragenter', (e) ->
    e.preventDefault()
    console.log 'dragenter'

  $('#dropzone').on 'dragleave,dragend', () ->
    console.log('dragleave,dragend')
    return false
