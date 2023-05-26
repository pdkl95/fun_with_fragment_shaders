#!/bin/bash

if (( $# != 2 )) ; then
    echo "usage: $0 <shader_src> <viewer_dst>"
    exit 1
fi

declare shader_src="$1"
declare viewer_dst="$2"

declare srcdir="$(dirname "${BASH_SOURCE[0]}")"
declare VIEWER_TEMPLATE="${srcdir}/viewer_template.html"

declare tmpdir="$(dirname "${viewer_dst}")"
declare tmpfile="$(mktemp --tmpdir="${tmpdir}" "$(basename "${viewer_dst}")-temp-XXXXXX")"

trap "rm -f \"${tmpfile}\"" INT TERM EXIT

fix_shader_src() {
    sed -re '
/#version 330/ d
/layout.*vec[234] frag_color/ d
/in vec[234] (position|color);/ d
s/(frag_color)(\s+=.*)/gl_FragColor\2/g
'
}

generate_viewer() {
    sed -e '/script id="customShader"/r'"$1" "${VIEWER_TEMPLATE}"
}

fix_shader_src <"${shader_src}" >"${tmpfile}"
generate_viewer "${tmpfile}" >"${viewer_dst}"


# Local Variables:
# mode: sh
# sh-basic-offset: 4
# sh-shell: bash
# coding: unix
# End:
