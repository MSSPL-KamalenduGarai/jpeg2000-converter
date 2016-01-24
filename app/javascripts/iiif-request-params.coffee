

class IIIFRequestParams
  constructor: (@url, @image_info) ->
    console.log @url
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
    reduction_factor = (@options.region.width / @options.size.width) - 1
    # since we know we have 6 quality layers and all tiles are
    # square we can fake this to be good enough for a proof
    # of concept.
    switch
      when reduction_factor >= 12 then 6
      when reduction_factor >= 10 then 5
      when reduction_factor >= 8 then 4
      when reduction_factor >= 6 then 3
      when reduction_factor >= 4 then 2
      when reduction_factor >= 2 then 1
      else 0

module.exports = IIIFRequestParams
