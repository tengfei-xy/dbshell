#!/bin/bash
self_filename=${0##*[\\/]}
info="
######################################################################
# Name: ${self_filename}
# Function: Start and stop script through utility
# Environment: Centos7.8 dm8
# Available Env: Centos7.x dm8
# Date: 2020/05/13
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
function checkDM() {
    case "$way" in
    systemd)
        test -z "$name" && JSONerr "You need to set a name for the service and enter a parameter named Name"
        ;;
    esac

    # if [ -r "$PWD"/dm.ini ];then

    # fi
}


function sql_run_stop() {
    case "$1" in
    startup)
        case "$way" in
        systemd)
            if ! systemctl start "DmService$name"  > "$LOG" ;then
                JSONerr "$_RET"
            else
                JSONSuccess
            fi
            ;;
        *)
            JSONerr "No useful boot method was found"
            ;;
        esac
    ;;

    shutdown)
        case "$way" in
        systemd)
            if ! systemctl stop "DmService$name"  > "$LOG" ;then
                JSONerr "$_RET"
            else
                JSONSuccess
            fi
            ;;
        *)
            JSONerr "No useful boot method was found"
            ;;
        esac
    ;;
    esac

}
function mainInit() {
    PWD=$(pwd)
    way="systemd"
    LOG=${self_filename}".log"
    ARGS=$(getopt -o "h?vb:de:w:n:" -l "way:,basedir:,help,exec:,debug,name:" -n "err" -- "$@")

    eval set -- "${ARGS}"
    while true; do
        case "${1}" in
        -w | --way)
            way=$2
            shift 2
            ;;
        -n | --name)
            name=$2
            shift 2
            ;;
        -b | --basedir)
            basedir=$2
            shift 2
            ;;

        -h | --help | "-?" | -v)
            echo -e "$info"
            echo -e "---------------------------------------"
            echo -e "args:"
            echo -e "-w|--way \t specify startup/shutdown way,Default:systemd"
            echo -e "-n|--name \t specify the instance name,Default:"
            echo -e "\t \t Values:systemd,"
            echo -e "-b|--basedir \t specift Mysql basedir,Default:"
            echo -e "other args:"
            echo -e "--help|-?|-v \t View script information, version information, help"
            echo -e "-d|--debug \t Only used for debugging in command line mode."
            echo -e "\t\tSuggest to put it in the first one."
            echo -e "---------------------------------------"
            echo -e "example:"
            echo -e "# shutdown the DM now"
            echo -e "${0} --exec shutdown --basedir /opt/dmdbms"
            echo -e "# startup the DM"
            echo -e "${0} -e startup -b /opt/dmdbms"

            exit 0
            ;;

        
        -e | --exec)
            exec=$2
            case "$2" in
            startup)
                
                ;;
            shutdown)
                
                ;;
            *)
                JSONerr "incorrect execute paramter:${2}"
                ;;
            esac
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
    checkDM
    sql_run_stop "$exec"
}
function mainOver() {
    trap '\rm -f "$LOG"' EXIT
}

mainInit "$@"
main
mainOver