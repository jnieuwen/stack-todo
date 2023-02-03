#! /bin/bash
# Copyright (c) 2021 Jeroen C. van Nieuwenhuizen. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. All advertising materials mentioning features or use of this software must
# display the following acknowledgement: This product includes software
# developed by Jeroen C. van Nieuwenhuizen.
#
# 4. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

export STACKTODOFILE="${STACKTODOFILE:-${HOME}/.todo-stack}"

function st-version() {
    echo "23.04.1"
}

function st-show() {
    if [ -f "${STACKTODOFILE}" ]
    then
        tail -n1 "${STACKTODOFILE}"
    fi
}

function st-push() {
    # Check if first elements are minutes.
    echo "$*" >> "${STACKTODOFILE}"
}

function st-top() {
    st-push "$@"
}

function st-add() {
    st-push "$@"
}

function st-shift() {
    echo "$*" > "${STACKTODOFILE}.tmp"
    cat "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-bottom() {
    st-shift "$@"
}

function st-next() {
    sed '$d' "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    echo "$*" >> "${STACKTODOFILE}.tmp"
    tail -n1 "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-pop() {
    tail -n1 "${STACKTODOFILE}" | sed 's/^/DONE: /'
    if [ -n "${STACKTODOLOGFILE}" ]
    then
        tail -n1 "${STACKTODOFILE}" >> "${STACKTODOLOGFILE}"
    fi
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '$d' "${STACKTODOFILE}"
    else
        sed -i'' '$d' "${STACKTODOFILE}"
    fi
    st-show
}

function st-rm() {
    tail -n1 "${STACKTODOFILE}" | sed 's/^/Deleted: /'
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '$d' "${STACKTODOFILE}"
    else
        sed -i'' '$d' "${STACKTODOFILE}"
    fi
    st-show
}

function st-rename() {
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '$d' "${STACKTODOFILE}"
    else
        sed -i'' '$d' "${STACKTODOFILE}"
    fi
    st-push "$@"
}

function st-commit() {
    git commit -m "$(tail -n1 "${STACKTODOFILE}")" || exit
    st-pop
}

function st-rev() {
    tac "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-dump() {
    tac "${STACKTODOFILE}"
}

function st-clear() {
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '1,$d' "${STACKTODOFILE}"
    else
        sed -i'' '1,$d' "${STACKTODOFILE}"
    fi
}

function st-edit() {
    "${EDITOR}" "${STACKTODOFILE}"
}

function st-bury() {
    tail -n1 "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    sed '$d' "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-file() {
    cat "${1}" >> "${STACKTODOFILE}"
}

function st-rise() {
    grep -v "$*" "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    grep "$*" "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-lower() {
    grep "$*" "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    grep -v "$*" "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-labels {
    tr " " '\n' < "${STACKTODOFILE}" | grep "^@" | uniq
}

function st-filter {
    grep "$*" "${STACKTODOFILE}" | tac
}


function st-swap() {
    sed '$d' "${STACKTODOFILE}" | sed '$d' > "${STACKTODOFILE}.tmp"
    tail -n2 "${STACKTODOFILE}" | tac >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-todoist-import {
    if [ -f "${HOME}/.todoist_api.key" ]
    then
        # Get the ones without a timestamp
        curl "https://api.todoist.com/rest/v2/tasks?token=$(cat "${HOME}/.todoist_api.key")&filter=%28assigned%20to:%20me%20|%20%21shared%29%20%26today" 2>/dev/null| \
            jq 'map(select(.due.datetime == null)) | sort_by(.due.datetime) | .[].content' >> "${STACKTODOFILE}"
        # Get the timestamp ones.
        curl "https://api.todoist.com/rest/v2/tasks?token=$(cat "${HOME}/.todoist_api.key")&filter=%28assigned%20to:%20me%20|%20%21shared%29%20%26today" 2>/dev/null| \
            jq 'map(select(.due.datetime != null)) | sort_by(.due.datetime) | .[].content' | tac >> "${STACKTODOFILE}"
    else
        echo "No ${HOME}/.todoist_api.key file present"
    fi
}

function st-count() {
    wc -l "${STACKTODOFILE}"
}

function st-before() {
    tac "${STACKTODOFILE}" | nl | grep "$*"
}

function st-log() {
    if [ -n "${STACKTODOLOGFILE}" ]
    then
        cat "${STACKTODOLOGFILE}"
    else
        echo "STACKTODOLOGFILE is undefined"
    fi
}
