$ = require('jquery')
url = require('url')


$(document).ready ->
  location = url.parse(window.location.href, true)
  image_id = location.query.id
  console.log image_id
  osd_config =
    id: 'openseadragon'
    prefixUrl: '../../node_modules/openseadragon/build/openseadragon/images/'
    preserveViewport: true
    visibilityRatio:    1
    minZoomLevel:       1
    defaultZoomLevel:   1
    sequenceMode:       true
    tileSources:   [  ]

  osd_config['tileSources']
    .push("http://localhost:3000/#{image_id}/info.json")

  console.log osd_config
  viewer = OpenSeadragon osd_config




# tileSources:   [
#   "@context": "http://iiif.io/api/image/2/context.json"
#   "@id": "http://libimages.princeton.edu/loris2/pudl0001%2F4609321%2Fs42%2F00000001.jp2"
#   "height": 7200
#   "width": 5233
#   "profile": [ "http://iiif.io/api/image/2/level2.json" ]
#   "protocol": "http://iiif.io/api/image"
#   "tiles": [
#     "scaleFactors": [ 1, 2, 4, 8, 16, 32 ]
#     "width": 1024
#   ]
# ]
