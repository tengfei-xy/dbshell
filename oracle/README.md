# Linux-Oracle-启停(run-stop)

说明文档适用的脚本版本：v0.3

## 说明

实现：通过SQLPLUS进行启停

适用数据库/操作系统范围： Centos7.x oracle 11g(not rac/dg)

## 使用方法

注：如果`which sqlplus`无法找到，则脚本运行失败并则返回`{"err":"Can't find sqlplus","status":"fail"}`

立即关闭实例

```shell
./linux-oracle-run-stop-v0.3.sh -exec shutdown -o immediate
```

启动实例

```shell
./linux-oracle-run-stop-v0.3.sh -exec startup
```

### 返回参数

该脚本只会返回一行JSON,如

```bash
[oracle@ora1 bbshell]$ ./linux-oracle-run-stop-v0.3.sh  -e startup
{"err":"","status":"success"}
# status表示执行操作后的结果,err会返回具体错误信息
# 如果status为success,则err恒空
```

```bash
[oracle@ora1 bbshell]$ ./linux-oracle-run-stop-v0.3.sh  -e shutdown 
{"err":"ORA-01034: ORACLE not available
ORA-27101: shared memory realm does not exist
Linux-x86_64 Error: 2: No such file or directory","status":"fail"}

# 输出内容的整体作为一行JSON
```

### 开启脚本调试

在执行某命令时加上`--debug`或`-d`即可，且建议放置于第一个位置，如下方命令所示

```
[oracle@ora1 dbshell]$ ./linux-oracle-run-stop-v0.3.sh --debug -e shutdown 
```

## 注意事项

不支持rac、dg以及其他版本的数据库，这些环境尚未测试。

## 版本信息

| 版本号 | 更新说明                                  | MD5                              |
| ------ | ----------------------------------------- | -------------------------------- |
| V0.1   | 2021/04/26-用SQLPLUS进行启停              | 573504a0297c7b09d1e94b2717dd0be6 |
| v0.3   | 2021/04/27-使用英文                       | 6f8eb604030c50b9a9ac72242acd50d1 |
| v0.3   | 2021/05/12-修复长选项的参数无法使用的问题 | 6c9b50c005e8de0aea64f9d062662335 |

