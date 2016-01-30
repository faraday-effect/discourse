/**
 * Created by tom on 1/12/16.
 */

var gulp = require('gulp');
var exec = require('gulp-exec');

gulp.task('adoc', function() {
    return gulp.src('./course/**/*.adoc')
        .pipe(exec('rake'))
        .pipe(exec.reporter());
});

gulp.task('default', function() {
    gulp.watch('./course/**/*.{adoc,jpg,png}', ['adoc']);
});
