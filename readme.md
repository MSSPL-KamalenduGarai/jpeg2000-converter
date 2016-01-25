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
- When processing an individual image give a status update on where through the process it is instead of just giving a spinner.
- Add size of original image to each line
- When images start to process hide the file drop target
- Add thumbnail images async
- Add button to start over
- Animate or highlight "all done" when images are finished processing
- Add settings to allow changing the directory that the files get saved in.
- Clean up temp files.
- Create a video showing how this works

## Author

Jason Ronallo

## License

MIT © North Carolina State University
