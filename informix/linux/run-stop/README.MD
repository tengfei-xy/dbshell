# Linux-informix-启停(run-stop)

说明文档适用的脚本版本：v0.1

## 说明

实现：通过oninit/onmode实现启停。

适用数据库/操作系统范围：Centos7.x informix 14.x

## 使用方法

启动数据库

```bash
[root@localhost informix]# ./linux-informix-run-stop-v0.1.sh --exec startup
 {"err":"","status":"success"}
```

停止数据库

```bash
[root@localhost informix]# ./linux-informix-run-stop-v0.1.sh -e shutdown -force
 {"err":"","status":"success"}
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@localhost dbshell]$ ./linux-informix-run-stop-v0.1.sh --debug -e shutdown 
```

## 注意事项

oninit/onmode应包含在PATH中

## 版本信息

| 版本号 | 更新说明                               | MD5                              |
| ------ | -------------------------------------- | -------------------------------- |
| V0.1   | 2021/05/13-用oninit/onmode方式进行启停 | ac28dac942473696e512febd9247957f |
|        |                                        |                                  |
|        |                                        |                                  |

