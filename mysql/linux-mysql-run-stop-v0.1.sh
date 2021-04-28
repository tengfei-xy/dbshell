#!/bin/bash
# md5sum:9dfac1fc8ad86b87efae67d56c120676
info="
linux系MySQL启停脚本\n
脚本说明:启停方式是通过mysql.service文件进行的,暂不支持直接的mysqld_safe启动
测试环境:Centos 7.8、非MGR、MySQL5.7/8 \n
shell:bash-4.2.46\n
修订时间:2020/04/27\n
"
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

}
function existMySQL() {
    mysql=$(which mysql 2>/dev/null)
    test -r "$mysql" || JSONerr "未发现mysql"

    execSQL "select @@basedir;"
    basedir=$(echo "$_RET" | grep "@@basedir" -o | grep "/.*" -o)
    test -r "$basedir" && JSONerr "basedir读取错误"

    systemctl status mysqld.service > /dev/null 2>&1
    if [ ! $? ] ;then
        mysql_server=${basedir}support-files/mysql.server > /dev/null 2>&1
        test -r "${mysql_server}" && mysqld_server=${mysql_server} && way=2
        test -r "/etc/init.d/mysql.service" && mysqld_server=/etc/init.d/mysql.service && way=3
    else        
        way=1
    fi

}
function execSQL() {
    {
        test -n "${password}" && password="-p${password}"
$mysql -u "$user" "${password}" <<EOF
$1
EOF
} >"$TMP"
    _RET=$(cat "$TMP")
}

function sql_run_stop() {
    case "$way" in
        1)
            systemctl mysqld.server "$1" >$TMP;;
        2|3)
            $mysqld_server "$1">$TMP;;
        *)
            JSONerr "没有找到对应的mysql.server";;
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

    TMP=$(mktemp -u $TMP) || JSONerr "创建缓存文件失败"
    #ARGS=$(getopt -o "o:u:p:r:h?v:e:d" -l "option:,user:,password:,remote:,help:,exec:,debug:" -n "err args" -- "$@")
    ARGS=$(getopt -o "u:p:h?v:e:d" -l "user:,password:,help:,exec:,debug:" -n "err args" -- "$@")
    remote=""
    eval set -- "${ARGS}"
    while true; do
        case "${1}" in
        -u | --user)
            user=${2}
            shift 2
            ;;
        -p | --password)
            password=${2}
            shift 2
            ;;
        -r | --remote)
            remote=${2}
            shift 2
            ;;
        -h | --help | "-?" | -v)
            echo -e "$info"
            echo -e "---------------------------------------"
            echo -e "连接选项:"
            echo -e "-u|--user\t指定连接用户,默认:root"
            echo -e "-p|--password\t指定密码,默认:空"
            #echo -e "-r|--remote\t指定连接主机,参数,默认:本地"
            echo -e "其他:"
            echo -e "--help|-?|-v\t查看脚本信息、版本信息、帮助"
            echo -e "-d|--debug\t仅仅用于命令行方式的调试模式脚本"
            echo -e "试例:"
            echo -e "${0} -exec shutdown \t#关闭数据库"
            echo -e "${0} -e startup \t\t#启动数据库"

            exit 0
            ;;

        
        -e | --exec)
            exec=${2}
            if [ "$exec" != "startup" ] && [ "$exec" != "shutdown" ]; then
                JSONerr "错误的exec参数:${2}"
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
    existMySQL
    sql_run_stop "$exec"
}
function mainOver() {
    trap 'rm -f "$TMP"' EXIT
}

mainInit "$@"
main
mainOver
# ./support-files/mysql.server start
# Starting MySQL. SUCCESS!
