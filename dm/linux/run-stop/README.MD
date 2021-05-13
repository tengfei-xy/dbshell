# Linux-dm-启停(run-stop)

说明文档适用的脚本版本：v0.1

## 说明

实现：通过服务启动，支持以下方式

* systemctl start/stop DmServerice<instance name>

适用数据库/操作系统范围：Centos7.x/8.x dm8

## 使用方法

启动数据库

```bash
[root@localhost dm]# ./linux-dm-run-stop-v0.1.sh -e shutdown -n mydb
 {"err":"","status":"success"}
```

使用systemctl进行停止数据库

```bash
[root@localhost dm]# ./linux-dm-run-stop-v0.1.sh -e shutdown  -n mydb -w ststemd
 {"err":"","status":"success"}
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@localhost dm]$ ./linux-dm-run-stop-v0.1.sh --debug -e shutdown  -n mydb
```

## 注意事项

- 仅支持单个实例的动作

- 其他操作系统未进行测试

## 版本信息

| 版本号 | 更新说明                        | MD5                              |
| ------ | ------------------------------- | -------------------------------- |
| v0.1   | 2021/05/12-用server方式进行启停 | cb1682dbe3c310b300193d4891d99b77 |
|        |                                 |                                  |
|        |                                 |                                  |

