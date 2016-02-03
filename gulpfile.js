/**
 * Created by tom on 1/12/16.
 */

var gulp = require('gulp');
var exec = require('gulp-exec');
var path = require('path');

var argv = require('yargs')
    .usage("usage: $0 [--src dir] [--dst dir]")
    .option('source-dir', {
        describe: 'Source directory',
        default: '.',
        alias: 'src',
        type: 'string'
    })
    .option('server-dir', {
        describe: 'Server directory',
        default: '.',
        alias: ['dst', 'dest'],
        type: 'string'
    })
    .help('h').alias('h', 'help')
    .argv;

function to_absolute_path(p) {
    if (path.isAbsolute(p)) {
        return p;
    }
    var working_dir = process.cwd();
    return path.join(working_dir, p);
}

function source_glob() {
    return path.join(to_absolute_path(argv.sourceDir), 'course', '**', '*.adoc');
}

function watch_glob() {
    return path.join(to_absolute_path(argv.sourceDir), 'course', '**', '*.{adoc,jpg,png}');
}

gulp.task('adoc', function() {
    return gulp.src(source_glob())
        .pipe(exec('rake'))
        .pipe(exec.reporter());
});

gulp.task('default', function() {
    gulp.watch(watch_glob(), ['adoc']);
});
