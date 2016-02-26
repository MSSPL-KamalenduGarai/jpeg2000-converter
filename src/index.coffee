'use strict'
# prevent window being garbage collected
mainWindow = undefined
installWindow = undefined
settingsWindow = undefined
kakaduInstalled = false
electron = require('electron')
shell = electron.shell
dialog = electron.dialog
app = electron.app
which = require('which')
kdu_compress = 'kdu_compress'

fs = require('fs')
Configstore = require('configstore')
package_json = require('../package.json')
expand_home_dir = require('expand-home-dir')
iiif_conversion_dir = expand_home_dir('~/iiif_conversion')

settings = new Configstore(package_json.name)

checkWhich = ->
  which kdu_compress, (err, path) ->
    if err #open a window with instructions on installing kakadu binaries
      installWindow = createInstallWindow()
    else
      kakaduInstalled = true
      installWindow.close() if installWindow?
      installWindow = null
      mainWindow = createMainWindow()

createMainWindow = ->
  if !mainWindow?
    win = new (electron.BrowserWindow)(
      width: 800
      height: 900
      icon: './app/images/image-image.png')
    win.setMenu(null)
    win.loadURL("file://#{__dirname}/views/index.html")
    win.on 'closed', ->
      win = null
    # win.output_dir = settings.get('output_dir')
    win.settings = settings
    win

createInstallWindow = ->
  win = new (electron.BrowserWindow)(
    width: 800
    height: 900
    # frame: false
    icon: './app/images/image-image.png')
  win.setMenu(null)
  win.loadURL("file://#{__dirname}/views/install.html")
  win.on 'closed', checkWhich
  win

openSettings = ->
  win = new (electron.BrowserWindow)(
    width: 400
    height: 200
    # frame: false
    icon: './app/images/image-image.png')
  win.setMenu(null)
  win.loadURL("file://#{__dirname}/views/settings.html")
  win.settings = settings
  win.on 'closed', ->
    settingsWindow = null
  win

# adds debug features like hotkeys for triggering dev tools and reload
# require('electron-debug')({showDevTools: true})

ipc_main = electron.ipcMain
ipc_main.on 'open-image', (event, arg) ->
  shell.openExternal(arg)

ipc_main.on 'open-jp2', (event, arg) ->
  jp2_window = new (electron.BrowserWindow)(
    show: false
    width: 1000
    height: 1000
    icon: './app/images/image-image.png'
  )
  jp2_window.setMenu(null)
  jp2_window.on 'closed', ->
    jp2_window = null
  encoded_image_path = encodeURIComponent arg
  url = "file://#{__dirname}/views/openseadragon.html?id=#{encoded_image_path}"
  jp2_window.loadURL(url)
  jp2_window.show()


ipc_main.on 'retry-launch', (event, arg) ->
  checkWhich()

ipc_main.on 'open-settings', (event, arg) ->
  if not settingsWindow?
    settingsWindow = openSettings()

ipc_main.on 'open-mainwindow-if-not', (event, arg) ->
  checkWhich()

app.on 'window-all-closed', ->
  if process.platform != 'darwin'
    app.quit()

app.on 'activate', ->
  if !mainWindow && kakaduInstalled
    mainWindow = createMainWindow()

app.on 'ready', ->
  # create the output directory if it doesn't exist already
  if !settings.get('output_dir')
    openSettings()
  else
    fs.stat settings.get('output_dir'), (err, stats) ->
      # console.log [err, stats]
      if err
        fs.mkdir settings.get('output_dir')
    checkWhich()

###
an express application
###
iiif = require 'iiif-image'
Informer = iiif.Informer('kdu')
Parser = iiif.ImageRequestParser
InfoJSONCreator = iiif.InfoJSONCreator
Extractor = iiif.Extractor('kdu')

express = require('express')
express_app = express()
_ = require('lodash')

express_app.get '*info.json', (req, res) ->
  url = req.url
  if _.includes(url, 'info.json')
    # console.log 'info.json'
    url_parts = url.split('/')
    id = url_parts[url_parts.length - 2]
    image_path = decodeURIComponent id
    scheme = if req.connection.encrypted? then 'https' else 'http'
    server_info =
      id: "#{scheme}://#{req.headers.host}/#{id}"
      level: 1
    info_cb = (info) ->
      info_json_creator = new InfoJSONCreator info, server_info
      # console.log info_json_creator.info_json
      res.send info_json_creator.info_json
    informer = new Informer image_path, info_cb
    informer.inform()

express_app.get '*.(jpg|png)', (req, res) ->
  url = req.url
  parser = new Parser url
  params = parser.parse()
  image_path = decodeURIComponent params.identifier

  extractor_cb = (image) ->
    res.setHeader 'Content-Type', 'image/jpeg'
    res.send image

  info_cb = (info) ->
    options =
      path: image_path
      params: params # from ImageRequestParser
      info: info
    extractor = new Extractor options, extractor_cb
    extractor.extract()

  informer = new Informer image_path, info_cb
  informer.inform()

express_app.listen 3000
