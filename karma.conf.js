// Karma configuration
// http://karma-runner.github.io/0.10/config/configuration-file.html

var fs = require('fs');
var _ = require('underscore');

module.exports = function( config ) {
  // build list of bower components from index.html
  // so we can inject them into the files loaded for testing
  var bowerScripts = [];
  var indexFile = fs.readFileSync( './app/index.html' );
  var finder = /<script.+src=['"]bower_components\/([^"']+)["']/gm;
  var match = null;
  while( (match = finder.exec(indexFile)) != null ) {
    var script = "app/bower_components/" + match[1];
    bowerScripts.push( script );
  }
  console.log("Injecting bower_components...\n", bowerScripts, "\n");

  config.set( {
    basePath: '',
    frameworks: ['mocha'],
    port: 8080,
    autoWatch: true,
    singleRun: false,

    files: _.flatten( [
      // assertion library
      'node_modules/expect.js/index.js',

      // injected bower components
      bowerScripts,

      // stubs out dropbox api
      'test/mock/**/*.coffee',

      'app/scripts/framework/**/*.coffee',
      'app/scripts/configure.coffee',
      'app/scripts/helpers.coffee',

      // karma doesn't know how to recompile templates
      '.tmp/scripts/templates.js',

      'app/scripts/models/**/*.coffee',
      'app/scripts/services/**/*.coffee',
      'app/scripts/views/**/*.coffee',
      'app/scripts/boot.coffee',

      // tests
      'test/spec/**/*.coffee'
    ] ),
    exclude: [],

    // possible values: LOG_DISABLE || LOG_ERROR || LOG_WARN || LOG_INFO || LOG_DEBUG
    logLevel: config.LOG_INFO,

    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['PhantomJS']
  } );
};
