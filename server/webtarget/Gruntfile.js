module.exports = function( grunt ) {
    grunt.initConfig( {
        pkg: grunt.file.readJSON( 'package.json' ),

        // install bower dependencies
        // options: https://github.com/yatskevich/grunt-bower-task
        bower: {
            install: {
                options: {
                    copy: true
                }
            }
        },

        // grunt clean task
        // options: https://github.com/gruntjs/grunt-contrib-clean
        clean: {
            dist: {
                options: { force: true },
                build: [ 'bower_components', 'lib', '../src/main/webapp/lib' ]
            },
            nodeModules: ['./node_modules']
        },

        // grunt copy task
        // options: https://github.com/gruntjs/grunt-contrib-copy
        copy : {
            main : {
                files: [ { expand: true, cwd: 'lib/', src: [ '**/*',  '!**/bootstrap-css-only/**' ], dest: '../src/main/webapp/lib' },
                         { expand: true, cwd: 'lib/bootstrap-css-only/', src: [ '*.css' ], dest: '../src/main/webapp/lib/bootstrap-css-only/css/' },
                         { expand: true, cwd: 'lib/bootstrap-css-only/', src: [ 'glyphicons*' ], dest: '../src/main/webapp/lib/bootstrap-css-only/fonts/' } ]
            }
        },
		
		// Connect: Dev server
		connect: {
		  options: {
			port: 9000,
			hostname: 'localhost',
			livereload: 35729
		  },
		  livereload: {
			options: {
			  open: true,
			  base: '../src/main/webapp'
			}
		  }
		},

		// Watch: Auto reload on file changes
		watch: {
		  options: {
			livereload: true
		  },
		  js: {
			files: ['../src/main/webapp/scripts/{,*/}*.js'],
		  },
		  html: {
			files: ['../src/main/webapp/{,*/}*.html'],
		  },
		  css: {
			files: ['../src/main/webapp/styles/{,*/}*.css'],
		  }
		}
    });

    grunt.loadNpmTasks( 'grunt-bower-task' );
    grunt.loadNpmTasks( 'grunt-contrib-clean' );
    grunt.loadNpmTasks( 'grunt-contrib-copy' );
	grunt.loadNpmTasks('grunt-contrib-connect');
	grunt.loadNpmTasks('grunt-contrib-watch');
	

    grunt.registerTask( 'resolve', [ 'clean:dist', 'bower:install', 'copy' ] );
	grunt.registerTask( 'serve',  ['connect:livereload','watch'] );
};
