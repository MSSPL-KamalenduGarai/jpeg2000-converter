$ = require('jquery')
tempfile = require('tempfile')
child_process = require('child_process')
async = require('async')
pather = require('path')
electron = require('electron')
fs = require('fs')
prettysize = require('prettysize')
settings = electron.remote.getCurrentWindow().settings

# For some reason sharp does not do a good job of converting some images
# to a TIFF that kdu_compress will like so we use imagemagick.
convert_to_tiff = (path, tif_tmp, async_callback) ->
  convert_cmd = "convert #{path} #{tif_tmp}"
  child_process.exec convert_cmd,
    (stdout, stderr) ->
      console.log "tiff: #{tif_tmp}"
      async_callback()

tiff2rgba = (tif_tmp, tif_tmp_rgba, async_callback) ->
  child_process.exec("tiff2rgba -c none #{tif_tmp} #{tif_tmp_rgba}",
    (stdout, stderr) ->
      console.log "tiff2rgba: #{tif_tmp_rgba}"
      fs.unlinkSync(tif_tmp)
      async_callback()
  )

compress = (tif_tmp_rgba, output_file, async_callback) ->
  command_function =
    if settings.get('jp2_binary') == 'opj'
      opj_command
    else
      kdu_command
  cmd = command_function tif_tmp_rgba, output_file
  console.log cmd
  child_process.exec cmd, (stdout2, stderr2) ->
    console.log "jp2: #{output_file}"
    fs.unlinkSync(tif_tmp_rgba)
    async_callback()


update_completed_number = () ->
  completed_number_text = $('.completed_number').text()
  completed_number =
    if !!completed_number_text
    then parseInt(completed_number_text) + 1
    else 1
  $('.completed_number').html(completed_number)
  console.log "completed_number: #{completed_number}"

convert_image = (file_row, async_callback) ->
  console.log file_row
  path = $(file_row).children('.path-to-file').text()
  tif_tmp = tempfile('.tiff')
  tif_tmp_rgba = tempfile('.tif')
  extname = pather.extname(path)
  basename = pather.basename(path, extname)
  output_dir = settings.get('output_dir')
  jp2_file = pather.join(output_dir, basename + '.jp2')
  console.log jp2_file
  # convert to TIFF

  fr = $(file_row)
  async.series([
    (callback) ->
      fr.find('.status').html('beginning')
      fr.find('.fa-spinner').show()
      fr.addClass('working-line')
      $('body').animate({scrollTop: fr.offset().top, 100})
      callback()
    (callback) ->
      fr.find('.status').html('converting to tiff')
      convert_to_tiff(path, tif_tmp, callback)
    (callback) ->
      fr.find('.status').html('ensuring rgba tiff')
      tiff2rgba(tif_tmp, tif_tmp_rgba, callback)
    (callback) ->
      fr.find('.status').html('creating JP2')
      compress(tif_tmp_rgba, jp2_file, callback)
    (callback) ->
      fr.find('.status').html('<i class="fa fa-check"></i> completed')
      fr.find('.fa-spinner').hide()
      fr.find('.output-jp2-container').show()
      fr.find('.output-jp2').append(jp2_file)
      jp2_filesize = fs.statSync(jp2_file)["size"]
      fr.find('.jp2-filesize').html(prettysize(jp2_filesize))
      fr.removeClass('working-line')
      update_completed_number()
      console.log "original file processed: #{path}"
      $('#restart').show()
      callback()
      async_callback()
  ],
    (err, results) ->
      console.log [err, results]
  )

$(document).ready ->
  $("#convert-jpeg2000-command").on 'click', () ->
    $('#dropzone').hide()
    $('#convert-jpeg2000-command').hide()
    $("#convert-overall-spinner").show()
    # TODO: store files somewhere and then process from there instead of
    # from looking at the file page
    async.eachSeries(
      $('.file-row') # take each .file-row as file_row
      (file_row, callback) ->
        convert_image(file_row, callback)
      # once they are all done this callback gets triggered
      (err) ->
        new Notification("Image processing done!")
        $('body').animate({scrollTop: 0})
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

opj_command = (tif, output_file) ->
  """opj_compress -i #{tif} -o #{output_file} -r 2.5 -n 7 -c "[256,256]"  -b "64,64" -p RPCL -SOP -t 1024,1024 -TP R"""
