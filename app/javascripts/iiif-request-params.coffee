

class IIIFRequestParams
  constructor: (@url, @image_info) ->
    @url_parts = @url.split('/')
    @id = @url_parts[1]
    region = @url_parts[2]
    if region == 'full'
      [left, top, width, height] = [0, 0, @image_info.width, @image_info.height]
    else
      [left, top, width, height] = region.split(',')

    size_section = @url_parts[3]
    size =
      width: parseInt(size_section.split(',')[0])
    rotation = @url_parts[4]

    [quality, format] = @url_parts[5].split('.')

    @options =
      identifier: @id
      region:
        top: top
        left: left
        height: height
        width: width
      size: size
      rotation: rotation
      quality: quality
      format: format

    @options.reduction = @calculate_reduction()

  # TODO: don't fake this!
  calculate_reduction: () ->
    console.log @options
    tile_size = 1024
    # switch
    #   when size.width == tile_size then 2
    #   else 3
    reduction = (@options.region.width / @options.size.width) - 1
    if reduction > 6
      6
    else
      reduction

module.exports = IIIFRequestParams
