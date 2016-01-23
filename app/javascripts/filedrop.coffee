$ = require('jquery')
hbs_render = require("#{__dirname}/../javascripts/hbs_render")
sharp = require('sharp')
tempfile = require('tempfile')

handle_files = (files) ->
  for file in files
    temp = tempfile('.png')
    sharp(file.path).resize(null, 100).toBuffer().then(
      (output) ->
        image = output.toString('base64')
        line = hbs_render('file_row', {path: file.path,image: image })
        $('#container').prepend(line))
  # Note we don't need to ask permission!
  new Notification("#{files.length} image(s) added and ready to be processed!")
  $('#commands').show()

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
    $('#dropzone').removeClass('dragover')

  $('#dropzone').on 'dragover', (e) ->
    e.preventDefault()
    console.log 'dragover'
    return false

  $('#dropzone').on 'dragenter', (e) ->
    e.preventDefault()
    $('#dropzone').addClass('dragover')
    console.log 'dragenter'

  $('#dropzone').on 'dragleave,dragend', () ->
    console.log('dragleave,dragend')
    return false

  $('#file-select-trigger').on 'click', (e) ->
    e.preventDefault()
    console.log('file-select-trigger')
    input = $('#file-select-input')
    input.click()
    console.log input[0].files

  $('#file-select-input').on 'change', (e) ->
    # e.preventDefault()
    input = $('#file-select-input')
    handle_files(input[0].files)
