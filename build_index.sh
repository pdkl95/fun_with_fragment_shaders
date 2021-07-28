#!/bin/bash

if (( $# != 1 )) ; then
    echo "usage: $0 <shader_dir>"
    exit 1
fi

declare shader_dir="$1"

shader_files() {
    local name
    for file in "${shader_dir}"/*.frag.glsl ; do
        basename "${file}"
    done | sort
}

shader_index() {
    local file name view
    for file in $(shader_files) ; do
        name="${file%.frag.glsl}"
        view="${name}.html"
        echo "      <li><a href=\"${view}\">${name}</a></li>"
    done
}

header() {
    cat <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Fun with GLSL fragment shaders</title>
  </head>
  <body>
    <h1>Fun with GLSL fragment shaders</h1>
    <ul>
EOF
}

footer() {
    cat <<EOF
    </ul>
  </body>
</html>
EOF
}

header
shader_index
footer


# Local Variables:
# mode: sh
# sh-basic-offset: 4
# sh-shell: bash
# coding: unix
# End:
