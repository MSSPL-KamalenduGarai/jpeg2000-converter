IIIFInfo = require('./iiif-info')
tempfile = require('tempfile')
child_process = require 'child_process'
fs = require('fs')

class IIIFRequest
  constructor: (@url, @image_path) ->

  response_image: () ->
    url_parts = @url.split('/')
    id = url_parts[1]

    iiif_info = new IIIFInfo(@image_path, @id)
    info = iiif_info.info()

    region = url_parts[2]
    if region == 'full'
      [left, top, width, height] = [0, 0, 6000, 6000]
    else
      [left, top, width, height] = region.split(',')

    reduction = @calculate_reduction()
    size = url_parts[3]
    rotation = url_parts[4]
    [quality, format] = url_parts[5].split('.')
    request_options =
      identifier: id
      region:
        top: top
        left: left
        height: height
        width: width
      size: size
      rotation: rotation
      quality: quality
      format: format
      reduction: reduction
    image_file = @create_jpg(request_options)
    image = fs.readFileSync(image_file)

  create_jpg: (request_options) ->
    ro = request_options
    region = request_options.region
    jp2_file = @image_path
    temp_bmp = tempfile('.bmp')
    top = region.top/6000.0
    left = region.left/6000.0
    height = region.height/6000.0
    width = region.width/6000.0
    # console.log [top, left, height, width]
    kdu_expand_cmd = "kdu_expand
      -i #{jp2_file}
      -o #{temp_bmp}
      -region '{#{top},#{left}},{#{height},#{width}}'
      -reduce #{ro.reduction}"
    console.log kdu_expand_cmd
    kdu_expand_result = child_process.execSync(kdu_expand_cmd)
    temp_jpg = tempfile('.jpg')
    size = ro.size.split(',')[0]
    convert_cmd = "convert #{temp_bmp} -resize #{size} #{temp_jpg}"
    convert_result = child_process.execSync(convert_cmd)
    temp_jpg


  calculate_reduction: ->
    4

module.exports = IIIFRequest
