#! /bin/bash
export STACKTODOFILE="${STACKTODOFILE:-${HOME}/.todo-stack}"

function st-show() {
    if [ -f "${STACKTODOFILE}" ]
    then
        # TODO fix mac vs linux
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
    sed -i '' '$d' "${STACKTODOFILE}"
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
    sed -i '' '1,$d' "${STACKTODOFILE}"
}
