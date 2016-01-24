parsexml = require('xml2js').parseString
child_process = require 'child_process'
util = require('util')

class IIIFInfo
  constructor: (@image_path, @id) ->

  kdu_info: ->
    kdu_info_cmd = "kdu_jp2info -siz -boxes 1 -com -i #{@image_path}"
    info = null
    kdu_info_result = child_process.execSync(kdu_info_cmd)
    parsexml kdu_info_result, (err, result) ->
      # console.log util.inspect result, false, null
      info = result
    # console.log kdu_info_result.toString()
    info

  info: ->
    info = @info_start()
    kinfo = @kdu_info()
    # console.log util.inspect info
    jpc = kinfo.JP2_family_file.jp2c[0]
    codestream = jpc.codestream[0]
    info['height'] = parseInt codestream.height[0]
    info['width'] = parseInt codestream.width[0]
    info

  info_start: ->
    '@context': "http://iiif.io/api/image/2/context.json"
    'protocol': "http://iiif.io/api/image"
    '@id': "http://localhost:3000/#{@id}"
    'profile': [
      "http://iiif.io/api/image/2/level2.json",
      {'qualities': ['default']}
    ]


# i =
#   new IIIFInfo '/home/jnronall/iiif_conversion/hs-2006-01-a-hires_tif.jp2',
#     'hs-2006-01-a-hires_tif'
#
# kdu_info = i.kdu_info()
# console.log util.inspect kdu_info, false, null
# console.log "\n\n"
# info = i.info()
# console.log util.inspect info, false, null

module.exports = IIIFInfo
