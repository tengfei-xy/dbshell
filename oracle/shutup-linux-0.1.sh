#!/bin/bash
#
info="
shutup-linux-${0##*[-]} \n
linux系oracle启停脚本\n
脚本说明:目前只支持环境:Centos 7.8、单节点、非dg、11g\n
shell:bash-4.2.46\n
修订时间:2020/04/27\n
"

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
function JSONerr(){
    _RET="" && JSONFill "err" "$1"
    exit 1
}
function JSONSuccess(){
    _RET="" && JSONFill "success"
    
}
function ExistSqlPlus() {
    sp=$(which sqlplus 2> /dev/null)
    # 当前是直接从PATH中中获取路径
    # 如果没有，应该修改成从$ORACLE_HOME中获取
    test $? -ne 0 && JSONerr "Can't find sqlplus"
    # 11.2.0.4.0
    sp_version_full=$($sp -version | grep "[[:digit:]].*\.[[:digit:]]" -o)
    # 11
    sp_verison_main=${sp_version_full%%[.]*}]
    
}
function sql_startup() {
    execSQLPlus "${exec} ${option}"

    # 没有启动报错
    if ! echo "$_RET" | grep "^ORA-[[:digit:]]*"  -o >/dev/null 2>&1
    then
        # 检查状态
        execSQLPlus "select status from v\$instance;"
        echo "$_RET" | grep "OPEN"  -o >/dev/null 2>&1 && test $? -eq 0 && JSONSuccess

    # 启动失败
    else
        JSONerr "${_RET}"
    fi

}
function sql_shutdown(){
    execSQLPlus "${exec} ${option}"

    # 关闭成功
    if echo "$_RET" | grep "^ORACLE instance shut down."  -o >/dev/null 2>&1
    then
        JSONSuccess
    # 关闭失败
    else
        JSONerr "${_RET}"
    fi
}
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

    TMP=$(mktemp -u $TMP)|| JSONerr "创建缓存文件失败"
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
                echo -e "连接选项:"
                echo -e "-u|--user\t指定连接用户,默认:sysdba用户"
                echo -e "-p|--password\t指定密码,默认:空"
                echo -e "-r|--remote\t指定连接主机,若远程,请参考sqlplus [@<connect_identifier>]参数,默认:本地"
                echo -e "执行操作:"
                echo -e "-o|--opteion\timmediate 立即关闭,force 强制启动,默认:空"
                echo -e "-e|--exec\t对实例操作,starup启动实例到归档日志模式,shutdown关闭实例"
                echo -e "其他:"
                echo -e "--help|-?|-v\t查看脚本信息、版本信息、帮助"
                echo -e "-d|--debug\t仅仅用于命令行方式的调试模式脚本"
                echo -e "试例:"
                echo -e "${0} -exec shutdown timmediate \t#立即关闭本地实例"
                echo -e "${0} -e startup \t\t#启动本地实例"

                exit 0
                ;;

            -o|--option)
                option=${2}
                if [ "$option" != "force" ] && [ "$option" != "immediate" ];then
                    JSONerr "错误的option参数:${2}"
                fi
                shift 2;
                ;;
            -e|--exec)
                exec=${2}
                if [ "$exec" != "startup" ] && [ "$exec" != "shutdown" ];then
                    JSONerr "错误的exec参数:${2}"
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