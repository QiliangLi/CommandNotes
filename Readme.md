## HDFS相关
### 基本命令
```sh
# ls
# 列出hdfs文件系统根目录下的目录和文件
hadoop fs -ls  /
# 列出hdfs文件系统所有的目录和文件
hadoop fs -ls -R /

# put
# hdfs file的父目录一定要存在，否则命令不会执行
hadoop fs -put < local file > < hdfs file >
# hdfs dir 一定要存在，否则命令不会执行
hadoop fs -put  < local file or dir >...< hdfs dir >
# 从键盘读取输入到hdfs file中，按Ctrl+D结束输入，hdfs file不能存在，否则命令不会执行
hadoop fs -put - < hdsf  file>

# rm
# 每次可以删除多个文件或目录
hadoop fs -rm < hdfs file > ...
hadoop fs -rm -r < hdfs dir>...

# erasure coding
# 查看编码块的分布
hdfs fsck /rs-6-3/file8064M -files -blocks -locations
hdfs fsck /rs-3-2/file8064M -files -blocks -locations

# 停止datanode进程
hdfs --daemon stop datanode

hadoop fs -rm /rs-6-3/*

hdfs dfs -mkdir /rs-6-3
hdfs ec -setPolicy -path /rs-6-3 -policy RS-6-3-1024k
hdfs ec -getPolicy -path /rs-6-3
hadoop fs -put ~/TestFile/file8064M /rs-6-3/

hdfs ec -enablePolicy  -policy RS-3-2-1024k
hdfs dfs -mkdir /rs-3-2
hdfs ec -setPolicy -path /rs-3-2 -policy RS-3-2-1024k
hdfs ec -getPolicy -path /rs-3-2
hadoop fs -put ~/TestFile/file8064M /rs-3-2/

hdfs ec -enablePolicy  -policy RS-10-4-1024k
hdfs dfs -mkdir /rs-10-4
hdfs ec -setPolicy -path /rs-10-4 -policy RS-10-4-1024k
hdfs ec -getPolicy -path /rs-10-4

```
[这里](http://bigdatastudy.net/show.aspx?id=458&cid=8) 有更多关于EC的Hadoop命令

### 实验相关
```sh
# 编译hadoop源码
mvn package -Pdist,native -DskipTests -Dtar

# 常用bash脚本命令
for i in {11..12};do ssh hadoop@n$i "sudo mount /dev/sdj1 /home/hadoop/echadoop";done

# 收集log
for i in {2,3,4};do ssh hadoop@node$i "hostname;tail -n 10 ~/echadoop/hadoop-3.1.2/logs/hadoop-hadoop-datanode-node$i.log" >> test;done

# 生成任意大小的文件
# if为输入文件名，of为输出文件名，bs为单次读取和写入的字节数，count为拷贝的次数，因而总文件大小为bs*count
# if为/dev/urandom——提供不为空字符的随机字节数据流
dd if=/dev/urandom of=file19680M count=19680 bs=1M
# 文件中的内容全部为\0空字符，输入文件是/dev/zero——一个特殊的文件，提供无限个空字符（NULL、0x00）
dd if=/dev/zero of=my_new_file count=102400 bs=1024
```
[这里](https://www.jianshu.com/p/81fc1297a7c4) 有更多关于Linux生成大文件的命令

## Linux相关

### 挂载磁盘相关命令
```sh
# 查看所有磁盘的顺序及类型
lsscsi

# 查看当前已挂载的磁盘
df -h

# 对已有数据的磁盘重新进行挂载，para1=磁盘文件路径，para2=挂载文件夹路径
sudo mount /dev/sdj1 /home/hadoop/echadoop

# 取消挂载,参数可以是设备，或者挂载点
sudo umount /dev/sdh1
sudo umount /home/hadoop/echadoop

# 添加开机自动挂载硬盘时要以UUID的方式，不要用绝对路径的方式，因为硬盘再每次启动后顺序可能会变
# 查看UUID
sudo blkid
# 注意：每次重建文件系统（格式化等），UUID都会变

# 添加开机自动挂载
sudo vi /etc/fstab
UUID=5c3dcf06-b781-4f5b-8542-3077be342814 /home/hadoop/echadoop ext4 defaults 0 0
UUID= /home/hadoop/echadoop ext4 defaults 0 0
UUID= /home/hadoop/TFiles ext4 defaults 0 0

# 查看可挂载的磁盘都有哪些
sudo fdisk -l

# 磁盘分区
sudo fdisk /dev/sdi
键入：m，可以看到帮助信息，
键入：n，添加新分区
键入：p，选择添加主分区
键入：l，选择主分区编号为1，这样创建后的主分区为sdi1
之后，fdisk会让你选择该分区的开始值和结束值，直接回车
最后键入：w，保存所有并退出，完成新硬盘的分区。

# 格式化磁盘
sudo mkfs -t ext4 /dev/sdi1
# 格式完磁盘之后就可以挂载，然后设置开机自动挂载

# bash
sleep 5s #延迟5s
sleep 5m #延迟5m
sleep 5h #延迟5h
sleep 5d #延迟5d

# 压缩
tar zcvf FileName.tar.gz DirName
# 解压
tar zxvf FileName.tar.gz

# 使用iperf测量worker1和worker2的带宽
# 在worker1运行
iperf -s
# 在worker2运行
iperf -c worker1

ps -aux|grep autoRun.sh| grep -v grep
ps -aux|grep schemeAutoRun.sh| grep -v grep
```

### 高效的Vi的命令
```sh
# 跳转指定行
:rowNum
```