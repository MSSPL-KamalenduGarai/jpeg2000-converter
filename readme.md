# JPEG2000 Converter

> A GUI for creating JPEG2000 images suitable for a IIIF image server

Written using Electron. Proof of concept.

## Requirements

You must have a JPEG2000 compression binary installed. The application works with either the open source OpenJPEG2 (opj_compress) or the proprietary Kakadu (kdu_compress) binaries.

For Mac OSX you will also need to [install libvips for sharp](http://sharp.dimens.io/en/stable/install/). Linux and Windows ought to already have libvips installed.

## Install

While this is probably in a pre-alpha state, please do give it a try and file issues.

You can either clone the repo and follow the development instructions below or [install one of the alpha packages](https://drive.google.com/folderview?id=0ByUq6R632zOwdkhiN3QwSHpoZzg&usp=sharing).

When you first run the application you'll be brought to the setup window where you can select an output directory (must exist) and which JP2 binary  you will be using for the conversion (select one you have installed).

## Development

Clone the repo and do:

```shell
npm install
```

### Run

```shell
npm start
```

### Watch and Compile

```shell
npm run foreman
```

### Build for release

```shell
npm run build:linux
npm run build:win
```

You should find a deb package in dist/linux and Windows installer in dist/win.

Builds the app for OS X, Linux, and Windows, using [electron-packager](https://github.com/maxogden/electron-packager).

## TODO
- Add thumbnail images async
- Create a video showing how this works
- Animate or highlight "all done" when images are finished processing
- after processing is complete for a file do some checks to make sure the JP2 has been created correctly. Size, `file`, what else?
- Allow for automatically installing dependencies if they are not installed
- Instead of requiring the user to click a button to relaunch the application just open the index page when the executables are installed?

## Author

Jason Ronallo

## License

MIT © North Carolina State University
