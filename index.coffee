onClosed = ->
  # dereference the window
  # for multiple windows store them in an array
  mainWindow = null
  return

createMainWindow = ->
  win = new (electron.BrowserWindow)(
    width: 600
    height: 900)
  # win.loadURL(`file://${__dirname}/index.html`);
  win.loadURL("file://#{__dirname}/app/views/index.html")
  win.on 'closed', onClosed
  win

'use strict'
electron = require('electron')
app = electron.app

fs = require('fs')
expand_home_dir = require('expand-home-dir')
iiif_conversion_dir = expand_home_dir('~/iiif_conversion')

# report crashes to the Electron project
require('crash-reporter').start()

# adds debug features like hotkeys for triggering dev tools and reload

require('electron-debug')({showDevTools: true})

# prevent window being garbage collected
mainWindow = undefined

ipc_main = require('electron').ipcMain
ipc_main.on('open-image', (event, arg) ->
  image_window = new (electron.BrowserWindow)(
    # width: 600
    # height: 300,
    show: false)
  image_window.on 'closed', ->
    jp2_window = null
  image_window.loadURL(arg)
  image_window.show()
)

ipc_main.on('open-jp2', (event, arg) ->
  jp2_window = new (electron.BrowserWindow)(
    show: false
  )
  jp2_window.on 'closed', ->
    jp2_window = null
  jp2_window
    .loadURL("file://#{__dirname}/app/views/openseadragon.html?id=#{arg}")
  jp2_window.show()
)

app.on 'window-all-closed', ->
  if process.platform != 'darwin'
    app.quit()

app.on 'activate', ->
  if !mainWindow
    mainWindow = createMainWindow()

app.on 'ready', ->
  mainWindow = createMainWindow()
  # create the output directory if it doesn't exist already
  mainWindow.iiif_conversion_dir = iiif_conversion_dir
  fs.stat(iiif_conversion_dir, (err, stats) ->
    # console.log [err, stats]
    if err
      fs.mkdir iiif_conversion_dir
  )


###
a koa application
###




koa = require('koa')
koa_app = koa()
_ = require('lodash')

koa_app.use (next) ->
  url = @.request.url

  # console.log "request url: #{url}"
  if _.includes(url, 'info.json')
    url_parts = url.split('/')
    id = url_parts[url_parts.length - 2]
    # console.log id
    @.body = extract_image_data(id)
  else
    # console.log url
    url_parts = url.split('/')
    # console.log url_parts
    id = url_parts[1]
    region = url_parts[2]
    if region == 'full'
      [left, top, width, height] = [0, 0, 6000, 6000]
    else
      [left, top, width, height] = region.split(',')

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
    image_file = create_jpg(request_options)
    image = fs.readFileSync(image_file)
    @.response.type = 'image/jpeg'
    @.response.body = image
    yield next

parsexml = require('xml2js').parseString
child_process = require 'child_process'
util = require('util')
pather = require('path')
tempfile = require('tempfile')

create_jpg = (request_options) ->
  ro = request_options
  region = request_options.region
  jp2_file =
    pather.join(iiif_conversion_dir, ro.identifier + '.jp2')
  temp_bmp = tempfile('.bmp')
  top = region.top/6000.0
  left = region.left/6000.0
  height = region.height/6000.0
  width = region.width/6000.0
  # console.log [top, left, height, width]
  kdu_expand_cmd = "kdu_expand
    -i #{jp2_file}
    -o #{temp_bmp}
    -region '{#{top},#{left}},{#{height},#{width}}'"
  console.log kdu_expand_cmd
  kdu_expand_result = child_process.execSync(kdu_expand_cmd)
  temp_jpg = tempfile('.jpg')
  size = ro.size.split(',')[0]
  convert_cmd = "convert #{temp_bmp} -resize #{size} #{temp_jpg}"
  convert_result = child_process.execSync(convert_cmd)
  temp_jpg

extract_image_data = (id) ->
  # TODO: set scaleFactors and width dynamically!
  info_start =
    '@context': "http://iiif.io/api/image/2/context.json"
    'protocol': "http://iiif.io/api/image"
    '@id': "http://localhost:3000/#{id}"
    'profile': [
      "http://iiif.io/api/image/2/level2.json",
      {'qualities': ['default']}
    ]
    # "tiles": [
    #   "scaleFactors": [ 1, 2, 4, 8, 16, 32 ]
    #   "width": 1024
    # ]
  info = kdu_info(id)
  # console.log "INFO"
  console.log util.inspect info
  jpc = info.JP2_family_file.jp2c[0]
  codestream = jpc.codestream[0]
  # console.log util.inspect jpc, depth: null
  info_start['height'] = parseInt codestream.height[0]
  info_start['width'] = parseInt codestream.width[0]
  # console.log util.inspect info_start
  info_start

kdu_info = (id) ->
  kdu_info_cmd = "kdu_jp2info -siz -i
    #{iiif_conversion_dir}/#{id}.jp2"
  info = null
  kdu_info_result = child_process.execSync(kdu_info_cmd)
  parsexml kdu_info_result, (err, result) ->
    # console.log util.inspect result, false, null
    info = result
  info

koa_app.listen 3000
