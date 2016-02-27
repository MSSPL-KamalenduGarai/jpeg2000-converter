$ = require('jquery')
electron = require 'electron'
shell = electron.shell
ipc_renderer = electron.ipcRenderer
which = require('which')

Configstore = require('configstore')
package_json = require('../../package.json')
settings = new Configstore(package_json.name)
check_interval = undefined

check_install_kdu = ->
  which 'kdu_compresss', (err, path) ->
    if path?
      settings.set 'jp2_binary', 'kdu'
      $('#kdu_compress-polling').hide()
      $('#retry-launch-section').show()
      $('#kdu_installed-launch').show()
      clearInterval(check_interval)

check_install_opj = ->
  which 'opj_compress', (err, path) ->
    if path?
      settings.set 'jp2_binary', 'opj'
      $('#opj_compress-polling').hide()
      $('#retry-launch-section').show()
      $('#opj_installed-launch').show()
      clearInterval(check_interval)

$(document).ready ->
  $('#open-install-kdu').on 'click', ->
    shell.openExternal('http://kakadusoftware.com/downloads/')
    $('#kdu_compress-polling').show()
    check_interval = setInterval ->
      check_install_kdu()
    , 1000

  $('#open-install-opj').on 'click', ->
    shell.openExternal('https://github.com/uclouvain/openjpeg')
    $('#opj_compress-polling').show()
    check_interval = setInterval ->
      check_install_opj()
    , 1000

  $('#retry-launch').on 'click', ->
    ipc_renderer.send('retry-launch')
