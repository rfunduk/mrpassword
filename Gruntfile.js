'use strict';

module.exports = function (grunt) {
  try {
    var DROPBOX_API_KEY = grunt.option('dropboxApiKey') ||
                          grunt.file.read('./.dropboxApiKey');
    DROPBOX_API_KEY = DROPBOX_API_KEY.replace(/[\n\s]/gi, '')
    console.log("** Configuring with Dropbox Datastore API key: '" + DROPBOX_API_KEY + "'");
  }
  catch( e ) {
    console.log(
      "** A Dropbox Datastore API key is required to run Mr. Password.\n" +
      "** Please provide a key via --dropboxApiKey='KEY' or in a file named .dropboxApiKey\n"
    );
    process.exit(1);
  }

  // Load grunt tasks automatically
  require('load-grunt-tasks')(grunt);

  // Time how long tasks take. Can help when optimizing build times
  require('time-grunt')(grunt);

  // Define the configuration for all the tasks
  grunt.initConfig({

    // Project settings
    yeoman: {
      // configurable paths
      app: require('./bower.json').appPath || 'app',
      dist: 'dist'
    },

    // Watches files for changes and runs tasks based on the changed files
    watch: {
      templates: {
        files: ['<%= yeoman.app %>/scripts/templates/**/*.hbs'],
        tasks: ['handlebars']
      },
      coffee: {
        files: ['<%= yeoman.app %>/scripts/**/*.{coffee,litcoffee,coffee.md}'],
        tasks: ['newer:coffee:dist', 'replace']
      },
      sass: {
        files: ['<%= yeoman.app %>/styles/**/*.{scss,sass}'],
        tasks: ['sass:dist', 'autoprefixer']
      },
      gruntfile: {
        files: ['Gruntfile.js'],
        tasks: ['dev']
      },
      // livereload: {
      //   options: {
      //     livereload: '<%= connect.options.livereload %>'
      //   },
      //   files: [
      //     '<%= yeoman.app %>/{,*/}*.html',
      //     '.tmp/styles/{,*/}*.css',
      //     '.tmp/scripts/{,*/}*.js',
      //     '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
      //   ]
      // }
    },

    replace: {
      dist: {
        options: {
          patterns: [
            {
              match: 'dropboxApiKey',
              replacement: DROPBOX_API_KEY,
              expression: false
            }
          ]
        },
        files: [{
          cwd: '.tmp',
          expand: true,
          src: ['**/*.js'],
          dest: '.tmp/'
        }]
      }
    },

    // The actual grunt server settings
    connect: {
      options: {
        port: 9000,
        // Change this to '0.0.0.0' to access the server from outside.
        hostname: 'localhost',
        // livereload: 35729
      },
      // livereload: {
      //   options: {
      //     open: false,
      //     base: [
      //       '.tmp',
      //       '<%= yeoman.app %>'
      //     ]
      //   }
      // },
      dev: {
        options: {
          port: 9000,
          base: [ '.tmp', '<%= yeoman.app %>' ]
        }
      },
      test: {
        options: {
          port: 9001,
          base: [ '.tmp', 'test', '<%= yeoman.app %>' ]
        }
      },
      dist: {
        options: {
          base: '<%= yeoman.dist %>'
        }
      }
    },

    // Empties folders to start fresh
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [ '.tmp', '<%= yeoman.dist %>/*', '!<%= yeoman.dist %>/.git*' ]
        }]
      },
      server: '.tmp'
    },

    // Add vendor prefixed styles
    autoprefixer: {
      options: {
        browsers: ['last 1 version']
      },
      dist: {
        files: [{
          expand: true,
          cwd: '.tmp/styles/',
          src: '{,*/}*.css',
          dest: '.tmp/styles/'
        }]
      }
    },

    // Compiles CoffeeScript to JavaScript
    coffee: {
      options: {
        sourceMap: true,
        sourceRoot: ''
      },
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '{,*/,*/*/}*.coffee',
          dest: '.tmp/scripts',
          ext: '.js'
        }]
      }
    },

    handlebars: {
      compile: {
        options: {
          namespace: function( path ) {
            var root = 'App.Templates';

            // remove source path
            path = path.replace('app/scripts/templates/', '');

            // split into path fragments
            var parts = path.split('/');

            // return plain root if we have no subdirs
            if( parts.length == 1 ) { return root; }

            // remove filename
            parts.pop();

            return root + '.' + parts.join('.');
          },
          processName: function( path ) {
            path = path.replace('app/scripts/templates/', '')
            return path.split('/').pop().replace(/-/g, '_').replace('.hbs', '');
          }
        },
        files: {
          ".tmp/scripts/templates.js": ['<%= yeoman.app %>/scripts/templates/{,*/}*.hbs']
        }
      }
    },

    // Compiles Sass to CSS and generates necessary files if requested
    // sass: {
    //   options: {
    //     loadPath: [
    //       '<%= yeoman.app %>/styles',
    //       '<%= yeoman.app %>/bower_components/'
    //     ],
    //     precision: 10,
    //     style: 'compact',
    //     trace: true
    //   },
    //   dist: {
    //     expand: true,
    //     cwd: '<%= yeoman.app %>/styles',
    //     src: 'main.scss',
    //     ext: '.css',
    //     dest: '.tmp/styles'
    //   }
    // },

    // grunt-sass now that it's working?
    sass: {
      options: {
        includePaths: [
          '<%= yeoman.app %>/styles',
          '<%= yeoman.app %>/bower_components/'
        ],
        precision: 10,
        outputStyle: 'compact',
        trace: true,
        sourceMap: true
      },
      dist: {
        expand: true,
        cwd: '<%= yeoman.app %>/styles',
        src: 'main.scss',
        ext: '.css',
        dest: '.tmp/styles'
      }
    },

    // Renames files for browser caching purposes
    rev: {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/fonts/{,*/,*/*/}*.{svg,ttf,woff,eot}',
            '<%= yeoman.dist %>/scripts/*.js',
            '<%= yeoman.dist %>/styles/*.css',
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
          ]
        }
      },
      // renames index.html to SHA.index.html for cache busting
      // on Amazon CloudFront
      deploy: {
        files: {
          src: [
            '<%= yeoman.dist %>/index.html'
          ]
        }
      }
    },

    // Reads HTML for usemin blocks to enable smart builds that automatically
    // concat, minify and revision files. Creates configurations in memory so
    // additional tasks can operate on them
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },

    // Performs rewrites based on rev and the useminPrepare configuration
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/*.css'],
      options: {
        assetsDirs: [
          '<%= yeoman.dist %>',
          '<%= yeoman.dist %>/styles',
          '<%= yeoman.dist %>/scripts'
        ]
      }
    },

    // The following *-min tasks produce minified files in the dist folder
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg,gif}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },

    // Copies remaining files to places other tasks can use
    copy: {
      dist: {
        files: [
          {
            expand: true,
            dot: true,
            cwd: '<%= yeoman.app %>',
            dest: '<%= yeoman.dist %>',
            src: [ '*.{ico,png,txt}', '*.html', 'dropbox.js' ]
          },
          {
            expand: true,
            cwd: '<%= yeoman.app %>/bower_components/bootstrap-sass/vendor/assets/fonts/bootstrap',
            src: '*',
            dest: '<%= yeoman.dist %>/fonts/'
          },
          {
            expand: true,
            cwd: '.tmp/images',
            dest: '<%= yeoman.dist %>/images',
            src: ['generated/*']
          }
        ]
      },
      fonts: {
        expand: true,
        cwd: '<%= yeoman.app %>/bower_components/bootstrap-sass/vendor/assets/fonts/bootstrap',
        src: '*',
        dest: '.tmp/fonts/'
      },
      keepIndex: {
        src: '<%= yeoman.dist %>/*.index.html',
        dest: '<%= yeoman.dist %>/index.html'
      }
    },

    // Test settings
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        autoWatch: true,
        singleRun: false
      }
    }
  });


  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run(['dev', 'connect:dev', 'watch']);
  });

  grunt.registerTask('dev', [
    'clean:server',
    'copy:fonts',
    'handlebars',
    'coffee:dist',
    'sass:dist',
    'autoprefixer',
    'replace'
  ]);

  grunt.registerTask('test', [
    'clean:server',
    'copy:fonts',
    'handlebars',
    'coffee',
    'sass',
    'autoprefixer',
    'connect:test',
    'karma'
  ]);

  var buildTasks = [
    'clean:dist',
    'useminPrepare',
    'handlebars',
    'coffee',
    'replace',
    'sass:dist',
    'imagemin',
    'autoprefixer',
    'concat',
    'copy:dist',
    'cssmin',
    'uglify',
    'rev:dist',
    'usemin',
    'rev:deploy',
    'copy:keepIndex'
  ];

  grunt.registerTask('build', buildTasks);
  grunt.registerTask('default', ['test', 'build']);
};
