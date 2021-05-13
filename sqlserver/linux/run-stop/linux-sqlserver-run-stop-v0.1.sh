#!/bin/bash
self_filename=${0##*[\\/]}
info="
######################################################################
# Name: ${self_filename}
# Function: Start and stop script through server
# Environment: Centos7.8 SQLServer-2017
# Available Env: Centos7.x SQLServer-2017
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
function existSQLServer() {


    way=0
    if ！systemctl status mssql-server >/dev/null 2>&1 ;then
        way=2
    else
        way=1  
    fi

}
# For SQL Server, 
# start and stop do not need to use interactive mode for the time being
# function execSQL() {
#     {
# sqlcmd -S "$remote" -U "$user"  -P "${password}" <<EOF
# $1
# EOF
# } >"$LOG"
#     _RET=$(cat "$LOG")
# }

function sql_run_stop() {
    case "$way" in
        1)
            systemctl "$1" mssql-server > "$LOG"
            ;;
        *)
            JSONerr "No other way to start is supported"
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
    
    ARGS=$(getopt -o "u:p:h?v:de:" -l "user:,password:,help,exec:,debug," -n "err" -- "$@")
    remote=""
    eval set -- "${ARGS}"
    while true; do
        case "${1}" in
        -u | --user)
            user="SA"
            test -n "${2}" && user="${2}"
            shift 2
            ;;
        -p | --password)
            password=""
            test -n "${2}" && password="${2}"
            shift 2
            ;;

        -r | --remote)
            remote=${2}
            shift 2
            ;;
        -h | --help | "-?" | -v)
            echo -e "$info"
            echo -e "---------------------------------------"
            echo -e "connect args:"
            echo -e "-u|--user \t specify username,Default:SA"
            echo -e "-p|--password \t specify password,Default:"
            echo -e "-r|--remote \t specify remote SQL Sserver,Default:localhost"
            echo -e "-b|--basedir \t specift Mysql basedir,Default:"
            echo -e "other args:"
            echo -e "--help|-?|-v \t View script information, version information, help"
            echo -e "-d|--debug \t Only used for debugging in command line mode."
            echo -e "\t\tSuggest to put it in the first one."
            echo -e "---------------------------------------"
            echo -e "example:"
            echo -e "# shutdown the SQLServer now"
            echo -e "${0} --exec shutdown"
            echo -e "# startup the SQLServer"
            echo -e "${0} -e startup"

            exit 0
            ;;

        
        -e | --exec)
            case "$2" in
            startup)
                exec="start"
                ;;
            shutdown)
                exec="stop"
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
    existSQLServer
    sql_run_stop "$exec"
}
function mainOver() {
    trap '\rm -f ${LOG}' EXIT
}

mainInit "$@"
main
mainOver