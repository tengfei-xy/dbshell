# Linux-Oracle-启停(run-stop)

## 说明（v0.2）

实现：通过SQLPLUS进行启停

适用数据库/操作系统范围： Centos7.x oracle 11g(not rac/dg)

## 使用方法

注：如果`which sqlplus`无法找到，则脚本运行失败并则返回`{"err":"Can't find sqlplus","status":"fail"}`

立即关闭实例

```shell
./linux-oracle-run-stop-v0.2.sh -exec shutdown -o immediate
```

启动实例

```shell
./linux-oracle-run-stop-v0.2.sh -exec startup

### 返回参数

该脚本只会返回一行JSON,如

​```bash
[oracle@ora1 bbshell]$ ./linux-oracle-run-stop-v0.2.sh  -e startup
{"err":"","status":"success"}
# status表示执行操作后的结果,err会返回具体错误信息
# 如果status为success,则err恒空
```

```bash
[oracle@ora1 bbshell]$ ./linux-oracle-run-stop-v0.2.sh  -e shutdown 
{"err":"ORA-01034: ORACLE not available
ORA-27101: shared memory realm does not exist
Linux-x86_64 Error: 2: No such file or directory","status":"fail"}
# 输出内容的整体作为一行JSON
```

## 版本信息

| 版本号 | 更新说明                     | MD5                              |
| ------ | ---------------------------- | -------------------------------- |
| V0.1   | 2021/04/26-用SQLPLUS进行启停 | 573504a0297c7b09d1e94b2717dd0be6 |
| V0.2   | 2021/04/27-使用英文          | 6f8eb604030c50b9a9ac72242acd50d1 |
|        |                              |                                  |



