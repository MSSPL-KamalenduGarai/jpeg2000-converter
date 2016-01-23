onClosed = ->
  # dereference the window
  # for multiple windows store them in an array
  mainWindow = null
  return

createMainWindow = ->
  win = new (electron.BrowserWindow)(
    width: 600
    height: 300)
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
    console.log [err, stats]
    if err
      fs.mkdir iiif_conversion_dir
  )
