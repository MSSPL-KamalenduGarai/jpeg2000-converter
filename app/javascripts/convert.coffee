$ = require('jquery')
tempfile = require('tempfile')
sharp = require('sharp')
child_process = require('child_process')

kdu_compress = (tif, output_file) ->
  cmd = kdu_command(tif, output_file)


convert_image = (file_row) ->
  console.log file_row
  path = $(file_row).children('.path-to-file').text()
  tif_tmp = tempfile('.tiff')
  tif_tmp_rgba = tempfile('.tiff')
  jp2_file = tempfile('.jp2')
  # convert to TIFF
  $(file_row).find('.fa-spinner').show()
  sharp(path).toFile(tif_tmp).then(
    (err, info) ->
      console.log tif_tmp
      # make sure it is rgba: tiff2rgba -c none tif tif2
      child_process.exec("tiff2rgba -c none #{tif_tmp} #{tif_tmp_rgba}",
        (stdout, stderr) ->
          console.log tif_tmp_rgba
          cmd = kdu_command(tif_tmp_rgba, jp2_file)
          console.log cmd
          child_process.exec(cmd,
            (stdout2, stderr2) ->
              console.log [stdout2, stdout2]
              console.log jp2_file
              $(file_row).find('.fa-spinner').hide()
          )
      )
  )

$(document).ready ->
  $("#convert-jpeg2000-command").on 'click', () ->
    $('#convert-jpeg2000-command').hide()
    $("#convert-overall-spinner").show()
    # TODO: store files somewhere and then process from there instead of
    # from looking at the file page
    for file_row in $('.file-row')
      convert_image(file_row)


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
