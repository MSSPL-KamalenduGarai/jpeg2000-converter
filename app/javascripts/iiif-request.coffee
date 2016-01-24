IIIFInfo = require('./iiif-info')
IIIFRequestParams = require('./iiif-request-params')
tempfile = require('tempfile')
child_process = require 'child_process'
fs = require('fs')

class IIIFRequest
  constructor: (@url, @image_path) ->
    console.log "IIIFRequest url: #{@url}"
    @url_parts = @url.split('/')
    @id = @url_parts[1]
    iiif_info = new IIIFInfo(@image_path, @id)
    @image_info = iiif_info.info()
    @params = new IIIFRequestParams(@url, @image_info)

  response_image: () ->
    image_file = @create_jpg(@params.options)
    image = fs.readFileSync(image_file)

  create_jpg: (request_options) ->
    ro = request_options
    region = request_options.region
    jp2_file = @image_path
    temp_bmp = tempfile('.bmp')
    top = region.top/@image_info.width
    left = region.left/@image_info.width
    height = region.height/@image_info.width
    width = region.width/@image_info.width
    # console.log [top, left, height, width]
    kdu_expand_cmd = "kdu_expand
      -i #{jp2_file}
      -o #{temp_bmp}
      -region '{#{top},#{left}},{#{height},#{width}}'
      -reduce #{ro.reduction}"
    console.log @url
    console.log kdu_expand_cmd
    kdu_expand_result = child_process.execSync(kdu_expand_cmd)
    temp_jpg = tempfile('.jpg')
    convert_cmd = "convert #{temp_bmp} -resize #{ro.size.width} #{temp_jpg}"
    convert_result = child_process.execSync(convert_cmd)
    temp_jpg

module.exports = IIIFRequest
