#!/bin/bash
self_filename=${0##*[\\/]}
info="
######################################################################
# Name: ${self_filename}
# Introduction: Start and stop script thought db2start/db2stop utility
# Environment: Centos7.8 DB2 v11.5.5
# Available Env: Centos7.x DB2 v11.x
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
    exit 1
}
function JSONSuccess() {
    _RET="" && JSONFill "success"
    exit 0
}
function existDB() {
    
    if ! which db2start 2> /dev/null ;then
        JSONFill "no found db2start"
    fi

}

function sql_run_stop() {
    case "$1" in
        startup)
           db2start >/dev/null 2>&1
           ;;
        shutdown)
            db2stop >/dev/null 2>&1
            ;;
    esac

    if [ "$?" -eq 0 ];then
        JSONSuccess
    else
        JSONerr "$_RET"
    fi

}
function mainInit() {

    LOG=${self_filename}".log"
    
    ARGS=$(getopt -o "h?vb:de:" -l "help,exec:,debug," -n "err" -- "$@")

    eval set -- "${ARGS}"
    while true; do
        case "${1}" in

        -h | --help | "-?" | -v)
            echo -e "$info"
            echo -e "---------------------------------------"
            echo -e "other args:"
            echo -e "--help|-?|-v \t View script information, version information, help"
            echo -e "-d|--debug \t Only used for debugging in command line mode."
            echo -e "\t\tSuggest to put it in the first one."
            echo -e "---------------------------------------"
            echo -e "example:"
            echo -e "# shutdown the DB2 now"
            echo -e "${0} --exec shutdown"
            echo -e "# startup the DB2"
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