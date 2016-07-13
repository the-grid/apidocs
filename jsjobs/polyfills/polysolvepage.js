

// JsJob compatibility wrapper script for poly
window.jsJobRun = function(data, o, callback) {
  var isDefined = function(obj) {
    return typeof obj != 'undefined' && obj != null;
  };
  var setIfNotDefined = function(obj, key, val) {
    if (!isDefined(obj[key])) {
      obj[key] = val;
    }
  };

  var options = {};
  if (isDefined(data.options)) {
    options = data.options;
  }

  window.polySolvePage(data, options, function (err, result, details) {
    if (err) {
      // Inject page info to error
      err.site = data.site;
      err.path = data.path;
      err.style = data.style;
      err.job = data.job;
      err.options = data.options;
      setIfNotDefined(err, 'job', null);
      setIfNotDefined(err, 'options', null);
      return callback(err);
    }

    var solved = {
      path: data.path,
      site: data.site,
      page: data.id,
      format: data.format,
      style: data.style,
      html: result,
      solution: details,
      staging: data.staging,
      review: data.review,
      job: data.job,
      options: data.options,
      gss: '',
      css: '',
    };
    setIfNotDefined(solved, 'staging', false);
    setIfNotDefined(solved, 'review', false);
    setIfNotDefined(solved, 'job', null);
    setIfNotDefined(solved, 'options', null);

    return callback(null, solved, details);
  });


};
