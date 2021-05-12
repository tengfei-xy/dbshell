# Linux-MySQL-启停(run-stop)

说明文档适用的脚本版本：v0.1

## 说明

实现：通过服务启动，支持以下三种方式

* support-files/mysql.server 
* /etc/init.d/mysql.service
* systemctl start/stop mysqld

适用数据库/操作系统范围：Centos7.x MySQL 5.7.x

## 使用方法

启动数据库

```bash
[root@localhost mysql]# ./linux-mysql-run-stop-v0.1.sh --exec startup --basedir /usr/local/mysql-5.7.27/
 {"err":"","status":"success"}
```

停止数据库

```bash
[root@localhost mysql]# ./linux-mysql-run-stop-v0.1.sh -e shutdown -b /usr/local/mysql-5.7.27/
 {"err":"","status":"success"}
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@localhost dbshell]$ ./linux-oracle-run-stop-v0.3.sh --debug -e shutdown 
```

## 注意事项

不支持远程关闭或MySQL8.x版本

## 版本信息

| 版本号 | 更新说明                        | MD5                              |
| ------ | ------------------------------- | -------------------------------- |
| V0.1   | 2021/05/12-用server方式进行启停 | d42cdf562f8f15b9d9c34e2e1d93889e |
|        |                                 |                                  |
|        |                                 |                                  |

