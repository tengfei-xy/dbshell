# Linux-MySQL-启停(run-stop)

说明文档适用的脚本版本：v0.2

## 说明

实现：通过服务启动，支持以下三种方式

* support-files/mysql.server 
* /etc/init.d/mysql.service
* systemctl start/stop mysqld

适用数据库/操作系统范围：Centos7.x MySQL 5.7.x

## 使用方法

启动数据库

```bash
[root@localhost mysql]# ./linux-mysql-run-stop-v0.2.sh --exec startup --basedir /usr/local/mysql-5.7.27/
 {"err":"","status":"success"}
```

停止数据库

```bash
[root@localhost mysql]# ./linux-mysql-run-stop-v0.2.sh -e shutdown -b /usr/local/mysql-5.7.27/
 {"err":"","status":"success"}
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@localhost dbshell]$ ./linux-mysql-run-stop-v0.2.sh --debug -e shutdown 
```

## 注意事项

不支持远程关闭或MySQL8.x版本

## 版本信息

| 版本号 | 更新说明                        | MD5                              |
| ------ | ------------------------------- | -------------------------------- |
| v0.1   | 2021/05/12-用server方式进行启停 | 94812dd70f364cc920ca373555d37617 |
| V0.2   | 2021/05/13-修改文字说明         | 86bedd3759204b01b33915d6d4679b4f |
|        |                                 |                                  |

