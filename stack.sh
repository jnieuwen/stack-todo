#! /bin/bash
export STACKTODOFILE=$HOME/.todo-stack

function st-show() {
    if [ -f "${STACKTODOFILE}" ]
    then
        tail -n1 "${STACKTODOFILE}" | sed 's/^/NOW: /'
    fi
}

function st-push() {
    echo "$*" >> "${STACKTODOFILE}"
}

function st-shift() {
    echo "$*" > "${STACKTODOFILE}.tmp"
    cat "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
}

function st-next() {
    sed '$d' "${STACKTODOFILE}" > "${STACKTODOFILE}.tmp"
    echo "$*" >> "${STACKTODOFILE}.tmp"
    tail -n1 "${STACKTODOFILE}" >> "${STACKTODOFILE}.tmp"
    mv "${STACKTODOFILE}.tmp" "${STACKTODOFILE}"
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
