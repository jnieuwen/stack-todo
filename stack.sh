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
    echo "v0.2"
}

function st-show() {
    if [ -f "${STACKTODOFILE}" ]
    then
        if [ "$(uname -s)x" = "Darwinx" ]
        then
            date -v"+$(awk 'BEGIN { sum=0} ; { sum+=$1} ; END { print sum }' "${STACKTODOFILE}")M" +"ETA: %H:%M"
        else
            date -d"+$(awk 'BEGIN { sum=0} ; { sum+=$1} ; END { print sum }' "${STACKTODOFILE}")minutes" +"ETA: %H:%M"
        fi
        tail -n1 "${STACKTODOFILE}" | sed 's/^/NOW: /'
    fi
}

function st-push() {
    # Check if first elements are minutes.
    if (( $1 )) 2>/dev/null
    then
        echo "$*" >> "${STACKTODOFILE}"
    else
        echo "Not in <minutes> <todo> format"
    fi
}

function st-shift() {
    # Check if first elements are minutes.
    if (( $1 )) 2>/dev/null
    then
        echo "$*" > "${STACKTODOFILE}.tmp"
        cat "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
        mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
    else
        echo "Not in <minutes> <todo> format"
    fi
}

function st-next() {
    # Check if first elements are minutes.
    if (( $1 )) 2>/dev/null
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
    cat "${STACKTODOFILE}"
}

function st-clear() {
    if [ "$(uname -s)x" = "Darwinx" ]
    then
        sed -i '' '1,$d' "${STACKTODOFILE}"
    else
        sed -i'' '1,$d' "${STACKTODOFILE}"
    fi
}
