#!/usr/bin/env bash

asciidoctor \
    --trace \
    --safe-mode unsafe \
    --load-path . \
    --require asciidoctor-sed \
    --attribute visuals_template=templates/visuals.html.erb \
    --attribute visuals_dir=../discourse-server/course/cos284/visuals \
    --destination-dir ../discourse-server/course/cos284/notes \
    course/cos284/intro.adoc
