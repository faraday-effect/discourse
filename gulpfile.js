/**
 * Created by tom on 1/12/16.
 */

var gulp = require('gulp');
var markdown = require('gulp-markdown');
var wrap = require('gulp-wrap');
var debug = require('gulp-debug');
var rename = require('gulp-rename');
var gutil = require('gulp-util');
var asciidoctor = require('gulp-asciidoctor');
var exec = require('gulp-exec');

var through = require('through2');
var hljs = require('highlight.js');
var chalk = require('chalk');

//const VISUAL_ENV = '#+VISUAL';
//const NOTES_ENV = '#+NOTES';
//const ANY_ENV = '#+';

//const env_details = { };
//env_details[VISUAL_ENV] = { start_block: '<div>', end_block: '</div>' };
//env_details[NOTES_ENV] = { start_block: '', end_block: '' };


function showContents (msg) {
    // Show the contents of the pipeline.
    return through.obj(function (file, encoding, callback) {
        blue = chalk.blue;
        if (msg) {
            gutil.log(blue(msg));
        }
        gutil.log(blue(file.path));
        console.log(chalk.yellow(file.contents.toString()));

        callback(null, file);
    });
}

//function extractEnvironment (env) {
//    return through.obj(function (file, encoding, callback) {
//        var inEnv = false;
//        var inputLines = file.contents.toString().split(/\r\n?|\n/);
//        var outputLines = [ ];
//
//        inputLines.forEach(function (line) {
//            gutil.log('Line', line);
//            if (line.indexOf(env) === 0) {
//                // Beginning of this environment
//                if (inEnv) {
//                    // Already in the environment; stop the current block
//                    outputLines.push(env_details[env].end_block);
//                }
//                inEnv = true;
//                outputLines.push(env_details[env].start_block);
//                return;
//            } else if (inEnv && line.indexOf(ANY_ENV) === 0) {
//                // End of environment
//                inEnv = false;
//                outputLines.push(env_details[env].end_block);
//                return;
//            }
//
//            if (inEnv) {
//                // Within environment
//                outputLines.push(line);
//            }
//        });
//
//        if (inEnv) {
//            // Still in environment at end of input
//            outputLines.push(env_details[env].end_block);
//        }
//
//        file.contents = new Buffer(outputLines.join('\n'));
//        callback(null, file);
//    });
//}

//const markedOptions = {
//    highlight: function (code) {
//        return hljs.highlightAuto(code).value;
//    }
//};

//gulp.task('asciidoctor', function() {
//    return gulp.src('*.adoc')
//        .pipe(asciidoctor())
//        .pipe(gulp.dest('.'));
//});

gulp.task('adoc', function() {
    return gulp.src('course/*/*.adoc')
        .pipe(debug())
        .pipe(exec('asciidoctor -D ./build <%= file.path %>'))
        .pipe(exec.reporter());
});

gulp.task('notes', function() {
    return gulp.src('course/*/*.md')
        .pipe(rename(function(path) {
            path.dirname += '/notes'
        }))
        .pipe(markdown(markedOptions))
        .pipe(wrap({ src: 'templates/notes.hbs' }, null, { engine: 'handlebars' }))
        .pipe(gulp.dest('./build'));
});

gulp.task('visuals', function() {
    return gulp.src('course/*/*.md')
        .pipe(rename(function(path) {
            path.dirname += '/visuals'
        }))
        .pipe(extractEnvironment(VISUAL_ENV))
        .pipe(showContents('Before markdown'))
        .pipe(markdown(markedOptions))
        .pipe(showContents('After markdown'))
        .pipe(wrap({ src: 'templates/visuals.hbs' }, null, { engine: 'handlebars' }))
        .pipe(gulp.dest('./build'))
});

gulp.task('images', function () {
    return gulp.src('course/*/images/*.jpg')
        .pipe(gulp.dest('./build'))
});

gulp.task('default', ['notes', 'visuals', 'images']);

// gulp.watch('course/*.md', ['notes', 'visuals']);
// gulp.watch('course/images/*.jpg', ['images']);
