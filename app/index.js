// Generated by CoffeeScript 1.10.0
(function() {
  'use strict';
  var Configstore, IIIFInfo, IIIFRequest, _, app, checkWhich, createInstallWindow, createMainWindow, dialog, electron, expand_home_dir, fs, iiif_conversion_dir, installWindow, ipc_main, kakaduInstalled, kdu_compress, koa, koa_app, mainWindow, openSettings, package_json, settings, settingsWindow, shell, which;

  mainWindow = void 0;

  installWindow = void 0;

  settingsWindow = void 0;

  kakaduInstalled = false;

  electron = require('electron');

  shell = electron.shell;

  dialog = electron.dialog;

  app = electron.app;

  which = require('which');

  kdu_compress = 'kdu_compress';

  fs = require('fs');

  Configstore = require('configstore');

  package_json = require('../package.json');

  expand_home_dir = require('expand-home-dir');

  iiif_conversion_dir = expand_home_dir('~/iiif_conversion');

  settings = new Configstore(package_json.name);

  checkWhich = function() {
    return which(kdu_compress, function(err, path) {
      if (err) {
        return installWindow = createInstallWindow();
      } else {
        kakaduInstalled = true;
        if (installWindow != null) {
          installWindow.close();
        }
        installWindow = null;
        return mainWindow = createMainWindow();
      }
    });
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
      height: 200,
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

  require('crash-reporter').start();

  require('electron-debug')({
    showDevTools: true
  });

  ipc_main = require('electron').ipcMain;

  ipc_main.on('open-image', function(event, arg) {
    var image_window;
    if (_.includes(arg, 'tif')) {
      return shell.openExternal(arg);
    } else {
      image_window = new electron.BrowserWindow({
        width: 1000,
        height: 1000,
        show: false,
        icon: './app/images/image-image.png'
      });
      image_window.setMenu(null);
      image_window.on('closed', function() {
        return image_window = null;
      });
      image_window.loadURL(arg);
      return image_window.show();
    }
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
    if (!mainWindow && kakaduInstalled) {
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
  a koa application
   */

  IIIFInfo = require('./javascripts/iiif-info');

  IIIFRequest = require('./javascripts/iiif-request');

  koa = require('koa');

  koa_app = koa();

  _ = require('lodash');

  koa_app.use(function*(next) {
    var id, iiif_info, iiif_request, image, info, path, url, url_parts;
    url = this.request.url;
    if (_.includes(url, 'info.json')) {
      url_parts = url.split('/');
      id = url_parts[url_parts.length - 2];
      iiif_info = new IIIFInfo(decodeURIComponent(id));
      info = iiif_info.info();
      return this.body = info;
    } else {
      url_parts = this.url.split('/');
      id = url_parts[1];
      path = decodeURIComponent(id);
      iiif_request = new IIIFRequest(url, path);
      image = iiif_request.response_image();
      this.response.type = 'image/jpeg';
      this.response.body = image;
      return (yield next);
    }
  });

  koa_app.listen(3000);

}).call(this);
