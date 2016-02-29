// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var Configstore, Extractor, InfoJSONCreator, Informer, Parser, _, app, checkWhich, createInstallWindow, createMainWindow, dialog, electron, expand_home_dir, express, express_app, fs, iiif, iiif_conversion_dir, installWindow, ipc_main, jp2_binary, jp2_binary_compress, jp2_binary_installed, kdu_compress, mainWindow, openSettings, opj_compress, package_json, settings, settingsWindow, shell, which;

  mainWindow = void 0;

  installWindow = void 0;

  settingsWindow = void 0;

  jp2_binary_installed = false;

  electron = require('electron');

  shell = electron.shell;

  dialog = electron.dialog;

  app = electron.app;

  fs = require('fs');

  Configstore = require('configstore');

  package_json = require('../package.json');

  expand_home_dir = require('expand-home-dir');

  iiif_conversion_dir = expand_home_dir('~/iiif_conversion');

  settings = new Configstore(package_json.name);

  which = require('which');

  kdu_compress = 'kdu_compress';

  opj_compress = 'opj_compress';

  jp2_binary_compress = settings.get('jp2_binary') === 'kdu' ? kdu_compress : settings.get('jp2_binary') === 'opj' ? opj_compress : (settings.set('jp2_binary', 'opj'), opj_compress);

  jp2_binary = settings.get('jp2_binary');

  checkWhich = function() {
    console.log(settings.get('jp2_binary'));
    if (settings.get('jp2_binary')) {
      return which(jp2_binary_compress, function(err, path) {
        if (err) {
          return installWindow = createInstallWindow();
        } else {
          jp2_binary_installed = true;
          if (installWindow != null) {
            installWindow.close();
          }
          installWindow = null;
          return mainWindow = createMainWindow();
        }
      });
    } else {
      return installWindow = createInstallWindow();
    }
  };

  createMainWindow = function() {
    var win;
    if (mainWindow == null) {
      win = new electron.BrowserWindow({
        width: 800,
        height: 900,
        icon: './app/images/image-image.png'
      });
      win.setMenu(null);
      win.loadURL("file://" + __dirname + "/views/index.html");
      win.on('closed', function() {
        return win = null;
      });
      win.settings = settings;
      return win;
    }
  };

  createInstallWindow = function() {
    var win;
    win = new electron.BrowserWindow({
      width: 800,
      height: 900,
      icon: './app/images/image-image.png'
    });
    win.setMenu(null);
    win.loadURL("file://" + __dirname + "/views/install.html");
    win.on('closed', checkWhich);
    return win;
  };

  openSettings = function() {
    var win;
    win = new electron.BrowserWindow({
      width: 400,
      height: 500,
      frame: false,
      icon: './app/images/image-image.png'
    });
    win.setMenu(null);
    win.loadURL("file://" + __dirname + "/views/settings.html");
    win.settings = settings;
    win.on('closed', function() {
      return settingsWindow = null;
    });
    return win;
  };

  require('electron-debug')({
    showDevTools: false
  });

  ipc_main = electron.ipcMain;

  ipc_main.on('open-image', function(event, arg) {
    return shell.openExternal(arg);
  });

  ipc_main.on('open-jp2', function(event, arg) {
    var encoded_image_path, jp2_window, url;
    jp2_window = new electron.BrowserWindow({
      show: false,
      width: 1000,
      height: 1000,
      icon: './app/images/image-image.png'
    });
    jp2_window.setMenu(null);
    jp2_window.on('closed', function() {
      return jp2_window = null;
    });
    encoded_image_path = encodeURIComponent(arg);
    url = "file://" + __dirname + "/views/openseadragon.html?id=" + encoded_image_path;
    jp2_window.loadURL(url);
    return jp2_window.show();
  });

  ipc_main.on('retry-launch', function(event, arg) {
    return checkWhich();
  });

  ipc_main.on('open-settings', function(event, arg) {
    if (settingsWindow == null) {
      return settingsWindow = openSettings();
    }
  });

  ipc_main.on('open-mainwindow-if-not', function(event, arg) {
    return checkWhich();
  });

  app.on('window-all-closed', function() {
    if (process.platform !== 'darwin') {
      return app.quit();
    }
  });

  app.on('activate', function() {
    if (!mainWindow && jp2_binary_installed) {
      return mainWindow = createMainWindow();
    }
  });

  app.on('ready', function() {
    if (!settings.get('output_dir')) {
      return openSettings();
    } else {
      fs.stat(settings.get('output_dir'), function(err, stats) {
        if (err) {
          return fs.mkdir(settings.get('output_dir'));
        }
      });
      return checkWhich();
    }
  });


  /*
  an express application
   */

  iiif = require('iiif-image');

  Informer = iiif.Informer(jp2_binary);

  Parser = iiif.ImageRequestParser;

  InfoJSONCreator = iiif.InfoJSONCreator;

  Extractor = iiif.Extractor(jp2_binary);

  express = require('express');

  express_app = express();

  _ = require('lodash');

  express_app.get('*info.json', function(req, res) {
    var id, image_path, info_cb, informer, scheme, server_info, url, url_parts;
    url = req.url;
    if (_.includes(url, 'info.json')) {
      url_parts = url.split('/');
      id = url_parts[url_parts.length - 2];
      image_path = decodeURIComponent(id);
      scheme = req.connection.encrypted != null ? 'https' : 'http';
      server_info = {
        id: scheme + "://" + req.headers.host + "/" + id,
        level: 1
      };
      info_cb = function(info) {
        var info_json_creator;
        info_json_creator = new InfoJSONCreator(info, server_info);
        return res.send(info_json_creator.info_json);
      };
      informer = new Informer(image_path, info_cb);
      return informer.inform();
    }
  });

  express_app.get('*.(jpg|png)', function(req, res) {
    var extractor_cb, image_path, info_cb, informer, params, parser, url;
    url = req.url;
    parser = new Parser(url);
    params = parser.parse();
    image_path = decodeURIComponent(params.identifier);
    extractor_cb = function(image) {
      res.setHeader('Content-Type', 'image/jpeg');
      return res.send(image);
    };
    info_cb = function(info) {
      var extractor, options;
      options = {
        path: image_path,
        params: params,
        info: info
      };
      extractor = new Extractor(options, extractor_cb);
      return extractor.extract();
    };
    informer = new Informer(image_path, info_cb);
    return informer.inform();
  });

  express_app.listen(3000);

}).call(this);
