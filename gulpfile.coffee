gulp = require 'gulp'
mocha = require 'gulp-mocha'

gulp.task 'test', ->
  stream = gulp
    .src('spec/**/*.coffee', {
      read: false
    })
    .pipe(mocha({
      reporter: 'spec'
    }))

  return stream
