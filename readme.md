# JPEG2000 Converstion GUI

> A GUI for creating JPEG2000 images suitable for a IIIF images

Written using Electron. Proof of concept.

## Dev

```shell
$ npm install
```

### Run

```shell
$ npm start
```

### Build

```shell
$ npm run build
```

Builds the app for OS X, Linux, and Windows, using [electron-packager](https://github.com/maxogden/electron-packager).

## TODO
- Clean up temp files.
- Add thumbnail images async
- Create a video showing how this works
- Animate or highlight "all done" when images are finished processing
- after processing is complete for a file do some checks to make sure the JP2 has been created correctly. Size, `file`, what else?
- Allow tif images to be opened up in default external viewer
- Add "JP2" icon as an easy target for launching the openseadragon viewer
- Allow for automatically installing dependencies if they are not installed
- Instead of requiring the user to click a button to relaunch the application just open the index page when the executables are installed

## Author

Jason Ronallo

## License

MIT © North Carolina State University
