$ = require('jquery')
hbs_render = require("#{__dirname}/../javascripts/hbs_render")
sharp = require('sharp')
async = require('async')
modal = null
prettysize = require('prettysize')

# ipc_renderer = require('electron').ipcRenderer

handle_files = (files) ->
  image_number = $('.image_number').html()
  index = if image_number != '' then parseInt(image_number) else 0

  # ipc_renderer.send('files-being-added-dialog', files.length)

  async.each(
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
            line = hbs_render('file_row',
              {path: file.path, image: image, filesize: prettysize(file.size) })
            $('#container').prepend(line)
            index++
            $('.image_number').html(index)
            $('#commands').show()
            async_callback()
      )
    -> #done
      modal.close()
      # Note we don't need to ask permission!
      new Notification("#{index} image(s) added and ready to be processed!")
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
