$ = require('jquery')
tempfile = require('tempfile')
child_process = require('child_process')
async = require('async')

# For some reason sharp does not do a good job of converting some images
# to a TIFF that kdu_compress will like so we use imagemagick.
convert_to_tiff = (path, tif_tmp, async_callback) ->
  convert_cmd = "convert #{path} #{tif_tmp}"
  child_process.exec(convert_cmd,
    (stdout, stderr) ->
      console.log [stdout, stderr]
      console.log "tiff: #{tif_tmp}"
      async_callback()
  )

tiff2rgba = (tif_tmp, tif_tmp_rgba, async_callback) ->
  child_process.exec("tiff2rgba -c none #{tif_tmp} #{tif_tmp_rgba}",
    (stdout, stderr) ->
      console.log "tiff2rgba: #{tif_tmp_rgba}"
      async_callback()
  )

kdu_compress = (tif, output_file, async_callback) ->
  cmd = kdu_command(tif, output_file)
  child_process.exec(cmd, (stdout2, stderr2) ->
    console.log [stdout2, stderr2]
    console.log "jp2: #{output_file}"
    async_callback()
  )


convert_image = (file_row, async_callback) ->
  console.log file_row
  path = $(file_row).children('.path-to-file').text()
  tif_tmp = tempfile('.tiff')
  tif_tmp_rgba = tempfile('.tiff')
  jp2_file = tempfile('.jp2')
  # convert to TIFF
  $(file_row).find('.fa-spinner').show()

  async.series([
    (callback) ->
      convert_to_tiff(path, tif_tmp, callback)
    (callback) ->
      tiff2rgba(tif_tmp, tif_tmp_rgba, callback)
    (callback) ->
      kdu_compress(tif_tmp_rgba, jp2_file, callback)
    (callback) ->
      $(file_row).find('.fa-spinner').hide()
      $(file_row).find('.output-jp2').append(jp2_file)
      console.log "original file processed: #{path}"
      completed_number = +$('#completed_number').text() + 1
      $('.completed_number').html(completed_number)
      callback()
      async_callback()
  ],
    (err, results) ->
      console.log [err, results]
  )

$(document).ready ->
  $("#convert-jpeg2000-command").on 'click', () ->
    $('#convert-jpeg2000-command').hide()
    $("#convert-overall-spinner").show()
    # TODO: store files somewhere and then process from there instead of
    # from looking at the file page
    async.each(
      $('.file-row')
      (file_row, callback) ->
        convert_image(file_row, callback)
      # once they are all done this callback gets triggered
      (err) ->
        $("#convert-overall-spinner").hide()
        $("#all-done-checkmark").show()
    )

kdu_command = (tif, output_file) ->
  # These settings are suggested by Princeton
  "kdu_compress
    -rate
    2.4,1.48331273,.91673033,.56657224,.35016049,.21641118,.13374944,.08266171
    -precise
    Clevels=6 Cblk=\{64,64\}
    -jp2_space sRGB
    Cuse_sop=yes Cuse_eph=yes Corder=RLCP ORGgen_plt=yes ORGtparts=R
    Stiles=\{1024,1024\}
    -double_buffering 10
    -num_threads 4
    Creversible=no
    -no_weights
    -i #{tif} -o #{output_file}"
