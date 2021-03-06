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
    echo "21.24.5"
}

function st-show() {
    if [ -f "${STACKTODOFILE}" ]
    then
        time=0
        timecounter=0
        tail -n1 "${STACKTODOFILE}" | while read -r -n time line
        do
            timecounter=$(( timecounter + time ))
            if [ "$(uname -s)x" = "Darwinx" ]
            then
                echo "$(date -v+"${timecounter}M" +"%H:%M") ${line}"
            else
                echo "$(date -d+"${timecounter}minutes" +"%H:%M") ${line}"
            fi
        done
    fi
}

function st-push() {
    # Check if first elements are minutes.
    if [ "${1}" = '0' ] || (( $1 )) 2>/dev/null
    then
        echo "$*" >> "${STACKTODOFILE}"
    else
        echo "Not in <minutes> <todo> format"
    fi
}

function st-top() {
    st-push "$@"
}

function st-shift() {
    # Check if first elements are minutes.
    if [ "${1}" = '0' ] || (( $1 )) 2>/dev/null
    then
        echo "$*" > "${STACKTODOFILE}.tmp"
        cat "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
        mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
    else
        echo "Not in <minutes> <todo> format"
    fi
}

function st-bottom() {
    st-shift "$@"
}

function st-next() {
    # Check if first elements are minutes.
    if [ "${1}" = '0' ] || (( $1 )) 2>/dev/null
    then
        sed '$d' "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
        echo "$*" >> "${STACKTODOFILE}.tmp"
        tail -n1 "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
        mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
    else
        echo "Not in <minutes> <todo> format"
    fi
}

function st-pop() {
    tail -n1 "${STACKTODOFILE}" | sed 's/^/DONE: /'
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '$d' "${STACKTODOFILE}"
    else
        sed -i'' '$d' "${STACKTODOFILE}"
    fi
    st-show
}

function st-rev() {
    tac "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-dump() {
    timecounter=0
    time=0
    tac "${STACKTODOFILE}" | while read -r -n time line
    do
        timecounter=$(( timecounter + time ))
        if [ "$(uname -s)x" = "Darwinx" ]
        then
            echo "$(date -v+"${timecounter}M" +"%H:%M") ${line}"
        else
            echo "$(date -d+"${timecounter}minutes" +"%H:%M") ${line}"
        fi
    done
}

function st-clear() {
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '1,$d' "${STACKTODOFILE}"
    else
        sed -i'' '1,$d' "${STACKTODOFILE}"
    fi
}

function st-finish() {
    if [ -f "${STACKTODOFILE}" ]
    then
        if [ "$(uname -s)x" = "Darwinx" ]
        then
            date -v"+$(awk 'BEGIN { sum=0} ; { sum+=$1} ; END { print sum }' "${STACKTODOFILE}")M" +"ETA: %H:%M"
        else
            date -d"+$(awk 'BEGIN { sum=0} ; { sum+=$1} ; END { print sum }' "${STACKTODOFILE}")minutes" +"ETA: %H:%M"
        fi
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

function st-swap() {
    sed '$d' "${STACKTODOFILE}" | sed '$d' > "${STACKTODOFILE}.tmp"
    tail -n2 "${STACKTODOFILE}" | tac >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-todoist-import {
    if [ -f "${HOME}/.todoist_api.key" ]
    then
        # Get the ones without a timestamp
        curl "https://api.todoist.com/rest/v1/tasks?token=$(cat "${HOME}/.todoist_api.key")&filter=%28assigned%20to:%20me%20|%20%21shared%29%20%26today" 2>/dev/null| \
            jq 'map(select(.due.datetime == null)) | sort_by(.due.datetime) | .[].content' | sed 's/^/0 /' >> "${STACKTODOFILE}"
        # Get the timestamp ones.
        curl "https://api.todoist.com/rest/v1/tasks?token=$(cat "${HOME}/.todoist_api.key")&filter=%28assigned%20to:%20me%20|%20%21shared%29%20%26today" 2>/dev/null| \
            jq 'map(select(.due.datetime != null)) | sort_by(.due.datetime) | .[].content' | sed 's/^/0 /' | tac >> "${STACKTODOFILE}"
    else
        echo "No ${HOME}/.todoist_api.key file present"
    fi
}
