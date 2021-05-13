#!/bin/bash
self_filename=${0##*[\\/]}
info="
######################################################################
# Name: ${self_filename}
# Introduction: Start and stop script thought oninit/onmode utility
# Environment: Centos7.8 informix 14.10
# Available Env: Centos7.x informix 14.x
# Date: 2020/05/12
######################################################################"

_RET=""
function JSONString() {
    local _KEY=\"$1\"
    local _VALUE=\"$2\"
    _RET="${_RET}${_KEY}:${_VALUE}$3"
}
function JSONOutPut() {
    echo "{${_RET}}"
}
function JSONFill() {
    case $1 in
    err)
        JSONString "err" "$2" ","
        JSONString "status" "fail"
        ;;
    success)
        JSONString "err" "" ","
        JSONString "status" "success"
        ;;
    esac

    JSONOutPut
}
function JSONerr() {
    _RET="" && JSONFill "err" "$1"
}
function JSONSuccess() {
    _RET="" && JSONFill "success"
}
function existDB() {
    
    if ! which oninit >/dev/null 2>&1 ;then
        JSONFill "no found oninit"
    fi

}

function sql_run_stop() {
    case "$1" in
        startup)
           oninit -y >"$LOG" 2>&1
           ;;
        shutdown)
        
            onmode $force >"$LOG" 2>&1
            ;;
    esac

    if [ "$?" -eq 0 ];then
        JSONSuccess
    else
        JSONerr "$(cat "$LOG")"
    fi

}
function mainInit() {
    LOG=${self_filename}".log"
    
    ARGS=$(getopt -o "f:h?vb:de:" -l "force,basedir:,help,exec:,debug," -n "err" -- "$@")

    eval set -- "${ARGS}"
    while true; do
        case "${1}" in
        -f | --force)
        force="-ky"
        ;;
        -h | --help | "-?" | -v)
            echo -e "$info"
            echo -e "---------------------------------------"
            echo -e "args:"
            echo -e "-f|--force \t Useful only when shutdown"
            echo -e "other args:"
            echo -e "--help|-?|-v \t View script information, version information, help"
            echo -e "-d|--debug \t Only used for debugging in command line mode."
            echo -e "\t\tSuggest to put it in the first one."
            echo -e "---------------------------------------"
            echo -e "example:"
            echo -e "# shutdown the informix now"
            echo -e "${0} --exec shutdown"
            echo -e "# startup the informix"
            echo -e "${0} -e startup"

            exit 0
            ;;

        
        -e | --exec)
            exec=${2}
            if [ "$exec" != "startup" ] && [ "$exec" != "shutdown" ];then
                JSONerr "incorrect execute paramter:${2}"
            fi
            shift 2
            ;;
        -d | --debug)
            set -x
            shift
            ;;
        --)
            shift
            break
            ;;
        esac
    done
}

function main() {
    existDB
    sql_run_stop "$exec"
}
function mainOver() {
    trap 'rm -f "$LOG"' EXIT
}

mainInit "$@"
main
mainOver