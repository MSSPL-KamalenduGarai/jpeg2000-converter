// Generated by CoffeeScript 1.10.0
(function() {
  var IIIFInfo, IIIFRequest, IIIFRequestParams, child_process, fs, tempfile;

  IIIFInfo = require('./iiif-info');

  IIIFRequestParams = require('./iiif-request-params');

  tempfile = require('tempfile');

  child_process = require('child_process');

  fs = require('fs');

  IIIFRequest = (function() {
    function IIIFRequest(url, image_path) {
      var iiif_info;
      this.url = url;
      this.image_path = image_path;
      this.url_parts = this.url.split('/');
      this.id = this.url_parts[1];
      iiif_info = new IIIFInfo(this.image_path, this.id);
      this.image_info = iiif_info.info();
      this.params = new IIIFRequestParams(this.url, this.image_info);
    }

    IIIFRequest.prototype.response_image = function() {
      var image, image_file;
      image_file = this.create_jpg(this.params.options);
      image = fs.readFileSync(image_file);
      fs.unlink(image_file);
      return image;
    };

    IIIFRequest.prototype.create_jpg = function(request_options) {
      var convert_cmd, convert_result, height, jp2_file, kdu_expand_cmd, kdu_expand_result, left, region, ro, temp_bmp, temp_jpg, top, width;
      ro = request_options;
      region = request_options.region;
      jp2_file = this.image_path;
      temp_bmp = tempfile('.bmp');
      top = region.top / this.image_info.height;
      left = region.left / this.image_info.width;
      height = region.height / this.image_info.height;
      width = region.width / this.image_info.width;
      kdu_expand_cmd = "kdu_expand -i " + jp2_file + " -o " + temp_bmp + " -region '{" + top + "," + left + "},{" + height + "," + width + "}' -reduce " + ro.reduction;
      kdu_expand_result = child_process.execSync(kdu_expand_cmd);
      temp_jpg = tempfile('.jpg');
      convert_cmd = "convert " + temp_bmp + " -resize " + ro.size.width + " " + temp_jpg;
      convert_result = child_process.execSync(convert_cmd);
      fs.unlinkSync(temp_bmp);
      return temp_jpg;
    };

    return IIIFRequest;

  })();

  module.exports = IIIFRequest;

}).call(this);
