# Linux-sqlserver-启停(run-stop)

说明文档适用的脚本版本：v0.1

## 说明

实现：通过服务启动，支持以下方式

* systemctl start/stop SQLServerd

适用数据库/操作系统范围：Centos7.x/8.x SQLServer 2017 任意许可版本

## 使用方法

启动数据库

```bash
[root@localhost SQLServer]# ./linux-sqlserver-run-stop-v0.1.sh --exec startup
 {"err":"","status":"success"}
```

停止数据库

```bash
[root@localhost SQLServer]# ./linux-sqlserver-run-stop-v0.1.sh -e shutdown
 {"err":"","status":"success"}
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@localhost dbshell]$ ./linux-sqlserver-run-stop-v0.1.sh --debug -e shutdown 
```

## 注意事项

- 不支持远程关闭

- 其他操作系统或数据库版本未进行测试

## 版本信息

| 版本号 | 更新说明                        | MD5                              |
| ------ | ------------------------------- | -------------------------------- |
| v0.1   | 2021/05/12-用server方式进行启停 | cb1682dbe3c310b300193d4891d99b77 |
|        |                                 |                                  |
|        |                                 |                                  |

