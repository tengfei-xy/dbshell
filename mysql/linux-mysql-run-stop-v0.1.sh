#!/bin/bash
self_filename=${0##*[\\/]}
info="
######################################################################
# Name: ${self_filename}
# Function: Start and stop script through SQLPlus
# Instruction: This starts and stops from the mysql.service file.
#              Direct mysqld_safe starting is not supported for now.
# Environment: Centos7.8 MySQL 5.7.27
# Available Env: Centos7.x MySQL 5.7.x
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
function existMySQL() {


    way=0
    if ！systemctl status mysqld >/dev/null 2>&1 ;then
        way=2
    else
        test -z "${basedir}" && JSONerr "Invalid paramter:basedir"
        mysql="${basedir}/bin/mysql"
        mysql_server=${basedir}support-files/mysql.server > /dev/null 2>&1
        test -r "${mysql_server}" && mysqld_server=${mysql_server} && way=1 && return
        test -r "/etc/init.d/mysql.service" && mysqld_server=/etc/init.d/mysql.service && way=1    
    fi

}
function execSQL() {
    {
$mysql -u "$user" "-p${password}" <<EOF
$1
EOF
} >"$LOG"
    _RET=$(cat "$LOG")
}

function sql_run_stop() {
    case "$way" in
        1)
            $mysqld_server "$1" > "$LOG";;
        2)
            systemctl "$1" mysqld  > "$LOG";;
        *)
            JSONerr "not found support-files/mysql.server";;
    esac

    if [ "$?" -eq 0 ];then
        JSONSuccess
    else
        JSONerr "$_RET"
    fi
    # Mysql8支持命令行关闭，但不支持启动
    # execSQL "shutdown;"
    # if ! echo "$_RET" | grep "Query OK"; then
    #     JSONSuccess
    # else
    #     JSONerr "$_RET"
    # fi
}
function mainInit() {

    LOG=${self_filename}".log"
    
    ARGS=$(getopt -o "u:p:h?vb:de:" -l "user:,password:,basedir:,help,exec:,debug," -n "err" -- "$@")
    remote=""
    eval set -- "${ARGS}"
    while true; do
        case "${1}" in
        -u | --user)
            user="root"
            test -n "${2}" && user="${2}"
            shift 2
            ;;
        -p | --password)
            password=""
            test -n "${2}" && password="${2}"
            shift 2
            ;;
        -b | --basedir)
            basedir=$2
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
            echo -e "-u|--user \t specify username,Default:root"
            echo -e "-p|--password \t specify password,Default:"
            echo -e "-r|--remote \t specify remote mysql server,Default:local way"
            echo -e "-b|--basedir \t specift Mysql basedir,Default:"
            echo -e "other args:"
            echo -e "--help|-?|-v \t View script information, version information, help"
            echo -e "-d|--debug \t Only used for debugging in command line mode."
            echo -e "\t\tSuggest to put it in the first one."
            echo -e "---------------------------------------"
            echo -e "example:"
            echo -e "# shutdown the MySQL now"
            echo -e "${0} --exec shutdown --basedir /usr/local/mysql-5.7.27/"
            echo -e "# startup the MySQL"
            echo -e "${0} -e startup -b /usr/local/mysql-5.7.27/"

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
    existMySQL
    sql_run_stop "$exec"
}
function mainOver() {
    trap 'rm -f "$LOG"' EXIT
}

mainInit "$@"
main
mainOver