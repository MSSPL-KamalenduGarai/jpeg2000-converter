$ = require('jquery')
hbs_render = require("#{__dirname}/../javascripts/hbs_render")
sharp = require('sharp')
async = require('async')
modal = null
prettysize = require('prettysize')
electron = require('electron')

# ipc_renderer = require('electron').ipcRenderer

handle_files = (files) ->
  image_number = $('.image_number').html()
  index = if image_number != '' then parseInt(image_number) else 0
  $('.image_number').html(files.length)
  # This is what we need to do to reverse the file list because FileList is
  # not an array and can't be reversed! But we want to process the last file
  # thumbnail first because we add new files to the top.
  file_list = []
  for file in files
    file_list.push file
  for file in file_list.reverse()
    line = hbs_render('file_row',
      {path: file.path, filesize: prettysize(file.size) })
    $('#container').prepend(line)
    modal.close()
    # Note we don't need to ask permission!
  new Notification("#{files.length} image(s) added and ready to be processed!")
  $('#commands').show()

  async.eachSeries(
    files
    (file, async_callback) ->
      console.log file
      sharp(file.path)
        .limitInputPixels(2147483647)
        .resize(null, 100)
        .toFormat('png')
        .toBuffer().then(
          (output) ->
            image = output.toString('base64')
            path = file.path
            img = $(".path-to-file:contains(#{path})").parent('.file-row').find('img')
            $(img[0]).prop 'src', "data:image/png;base64,#{image}"
            async_callback())
    -> #done

  )

open_files_added_modal = (number) ->
  $("#files-added-modal-number").html(number)
  modal = new Foundation.Reveal($('#files-added-modal'))
  modal.open()

$(document).ready ->
  $(document).on 'dragover,drop', (e) ->
    e.preventDefault()
    return false

  # http://stackoverflow.com/questions/21339924/drop-event-not-firing-in-chrome
  $('#dropzone').on 'drop', (e) ->
    e.preventDefault()
    console.log 'dropped'
    files = e.originalEvent.dataTransfer.files
    open_files_added_modal(files.length)
    handle_files(files)
    $('#dropzone').removeClass('dragover')

  $('#dropzone').on 'dragover', (e) ->
    e.preventDefault()
    # console.log 'dragover'
    return false

  $('#dropzone').on 'dragenter', (e) ->
    e.preventDefault()
    $('#dropzone').addClass('dragover')
    # console.log 'dragenter'

  $('#dropzone').on 'dragleave,dragend', () ->
    # console.log('dragleave,dragend')
    return false

  $('#file-select-trigger').on 'click', (e) ->
    e.preventDefault()
    # console.log('file-select-trigger')
    input = $('#file-select-input')
    input.click()

  $('#file-select-input').on 'change', (e) ->
    input = $('#file-select-input')
    files = input[0].files
    open_files_added_modal(files.length)
    handle_files(files)

  $('#restart').on 'click', (e) ->
    electron.remote.getCurrentWindow().reload()
    e.preventDefault()
