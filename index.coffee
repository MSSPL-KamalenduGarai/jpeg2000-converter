onClosed = ->
  # dereference the window
  # for multiple windows store them in an array
  mainWindow = null
  return

createMainWindow = ->
  win = new (electron.BrowserWindow)(
    width: 800
    height: 900
    icon: './app/images/image-image.png')
  win.loadURL("file://#{__dirname}/app/views/index.html")
  win.on 'closed', onClosed
  win

'use strict'
electron = require('electron')
dialog = electron.dialog
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
    width: 1000
    height: 1000
    show: false
    icon: './app/images/image-image.png')
  image_window.on 'closed', ->
    jp2_window = null
  image_window.loadURL(arg)
  image_window.show()
)

ipc_main.on('open-jp2', (event, arg) ->
  jp2_window = new (electron.BrowserWindow)(
    show: false,
    width: 1000,
    height: 1000
  )
  jp2_window.on 'closed', ->
    jp2_window = null
  jp2_window
    .loadURL("file://#{__dirname}/app/views/openseadragon.html?id=#{arg}")
  jp2_window.show()
)

# ipc_main.on('files-being-added-dialog', (event, arg) ->
#   dialog.showMessageBox(mainWindow, {
#     type: 'info',
#     message: "#{arg} files are being added...",
#     buttons: ['OK']
#     })
#
# )

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

IIIFInfo = require('./app/javascripts/iiif-info')
IIIFRequest = require('./app/javascripts/iiif-request')
koa = require('koa')
koa_app = koa()
_ = require('lodash')

image_path = (id) ->
  "#{iiif_conversion_dir}/#{id}.jp2"

koa_app.use (next) ->
  url = @.request.url
  if _.includes(url, 'info.json')
    url_parts = url.split('/')
    id = url_parts[url_parts.length - 2]
    iiif_info = new IIIFInfo(image_path(id), id)
    info = iiif_info.info()
    @.body = info
  else
    url_parts = @url.split('/')
    id = url_parts[1]
    iiif_request = new IIIFRequest(url, image_path(id))
    image = iiif_request.response_image()
    @.response.type = 'image/jpeg'
    @.response.body = image
    yield next


koa_app.listen 3000
