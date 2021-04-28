#!/bin/bash

info="
##############################
# Name: ${0##*[\\/]}
# Function: Start and stop script through SQLPlus
# Environment: Centos7.8 oracle 11.2.0.4 
# Apply Env: Centos7.x oracle 11g(not rac/dg)
# Date: 2020/04/27
##############################"

_RET=""
function JSONString() {
    local _KEY=\"$1\"
    local _VALUE=\"$2\"
    _RET="${_RET}${_KEY}:${_VALUE}$3"
}
function JSONOutPut(){
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
# this script outputs only a line of json
function JSONerr(){
    _RET="" && JSONFill "err" "$1"
    exit 1
}
function JSONSuccess(){
    _RET="" && JSONFill "success"
    exit 0
}
function ExistSqlPlus() {
    sp=$(which sqlplus 2> /dev/null)
    # Now,sqlplus is retrieved from $PATH
    # if not,It needs to by modified to be retrieved from $ORACLE_HOME
    test $? -ne 0 && JSONerr "Can't find sqlplus"
    # 11.2.0.4.0
    sp_version_full=$($sp -version | grep "[[:digit:]].*\.[[:digit:]]" -o)
    # 11
    sp_verison_main=${sp_version_full%%[.]*}]
    
}
function sql_startup() {
    execSQLPlus "${exec} ${option}"

    # startup no err
    if ! echo "$_RET" | grep "^ORA-[[:digit:]]*"  -o >/dev/null 2>&1
    then
        # check status
        execSQLPlus "select status from v\$instance;"
        echo "$_RET" | grep "OPEN"  -o >/dev/null 2>&1 && test $? -eq 0 && JSONSuccess

    # startup err
    else
        JSONerr "${_RET}"
    fi

}
function sql_shutdown(){
    execSQLPlus "${exec} ${option}"

    # shutdown success
    if echo "$_RET" | grep "^ORACLE instance shut down."  -o >/dev/null 2>&1
    then
        JSONSuccess
    # shutdown err
    else
        JSONerr "${_RET}"
    fi
}

# after exec sqlplus ,output to $TMP 
function execSQLPlus() {
{
$sp -S "$user"/"$password" "$remote" as sysdba <<EOF
$1
EOF
}> "$TMP"
    _RET=$(cat "$TMP")
}

# main
function mainInit() {

    TMP=$(mktemp -u $TMP)|| JSONerr "fail to make tmp file"
    ARGS=$(getopt -o "o:u:p:r:h?v:e:d" -l "option:,user:,password:,remote:,help:,exec:,debug:" -n "err args" -- "$@")
    remote=""
    eval set -- "${ARGS}"
    while true;
    do
        case "${1}" in
            -u|--user)
                user=${2}
                shift 2;
                ;;
            -p|--password)
                password=${2}
                shift 2;
                ;;
            -r|--remote)
                remote=${2}
                shift 2;
                ;;
            -h|--help|"-?"|-v)
                echo -e "$info"
                echo -e "---------------------------------------"
                echo -e "connect args:"
                echo -e "-u|--user \t specify username,Default:sysdba"
                echo -e "-p|--password \t specify password,Default:null"
                echo -e "-r|--remote \t specify connect identifier."
                echo -e "\t\t please reference sqlplus [@<connect_identifier>],Default:local"
                echo -e "execute args:"
                echo -e "-o|--option \t execute option"
                echo -e "\t\t 1.immediate,It be used for shutdown; "
                echo -e "\t\t 2.force,It be used for startup,Default:null"
                echo -e "-e|--exec \t operation on instance."
                echo -e "\t\t 1.starup,startup the instance into arived logging mode;"
                echo -e "\t\t 2.shutdown,shutdown the instacne"
                echo -e "other args:"
                echo -e "--help|-?|-v \t View script information, version information, help"
                echo -e "-d|--debug \t Only used for debugging in command line mode"
                echo -e "---------------------------------------"
                echo -e "example:"
                echo -e "# shutdown the instance now"
                echo -e "${0} -exec shutdown timmediate"
                echo -e "# startup the instace"
                echo -e "${0} -e startup"

                exit 0
                ;;

            -o|--option)
                option=${2}
                if [ "$option" != "force" ] && [ "$option" != "immediate" ];then
                    JSONerr "incorrect option parameter:${2}"
                fi
                shift 2;
                ;;
            -e|--exec)
                exec=${2}
                if [ "$exec" != "startup" ] && [ "$exec" != "shutdown" ];then
                    JSONerr "incorrect execute paramter:${2}"
                fi
                shift 2;
                ;;
            -d|--debug)
                set -x
                shift;
                ;;
            --)
                shift
                break
                ;;
        esac
    done
}

function main(){
    ExistSqlPlus
    if [ "$exec" = "startup" ];then sql_startup; fi
    if [ "$exec" = "shutdown" ];then sql_shutdown; fi
}
function mainOver(){
    trap 'rm -f "$TMP"' EXIT
}

mainInit "$@"
main
mainOver