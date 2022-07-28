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
hdfs ec -setPolicy -path / -policy RS-6-3-1024k

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
# target is busy
sudo fuser -cuk /home/hadoop/echadoop

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

# umount时出现device is busy
sudo fuser -km /data

# 删除磁盘所有分区
sudo mkfs.ext4 /dev/sdb

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

# 脚本后台运行，不受关闭终端的影响
nohup sh autoRun.sh &

# 查看后台运行的脚本
ps -aux|grep autoRun.sh| grep -v grep
ps -aux|grep schemeAutoRun.sh| grep -v grep

ps -aux|grep workloadAutoRun.sh| grep -v grep
ps -aux|grep wSchemeAutoRun.sh| grep -v grep

ps -aux|grep Simulate| grep -v grep

ps -aux|grep recovery| grep -v grep

ps -aux|grep heterogeneousAutoRun.sh| grep -v grep
ps -aux|grep heterogeneousSchemeAutoRun.sh| grep -v grep

# TC限速
sudo tc qdisc add dev ens9 root tbf rate 240Mbit latency 50ms burst 15kb
# 解除TC限速
sudo tc qdisc del dev ens9 root
# 列出所有的TC限速策略
sudo tc -s qdisc ls dev ens9 

# TC放大带宽 
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc add dev ens9 root tbf rate 280Mbit latency 50ms burst 250kb";done
# TC 30MB/s
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc add dev ens9 root tbf rate 250Mbit latency 50ms burst 250kb";done
for j in {1..19};do ssh hadoop@n$j "hostname;sudo tc qdisc del dev ens9 root";done

for j in {1..19};do ssh hadoop@n$j "hostname;sudo ~/wondershaper/wondershaper -a ens9 -d 240000 -u 240000";done
for j in {1..19};do ssh hadoop@n$j "hostname;sudo ~/wondershaper/wondershaper -c -a ens9";done

cd /home/qingya/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs-client
mvn package -Pdist -Dtar -DskipTests
cp /home/qingya/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs-client/target/hadoop-hdfs-client-3.1.2.jar /home/qingya/compile

cd /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs
mvn package -Pdist -Dtar -DskipTests
scp -r /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs/target/hadoop-hdfs-3.1.2/share/hadoop/hdfs hadoop@n$i:~/echadoop/hadoop-3.1.2/share/hadoop/

cp ~/SLECTIVEEC-src/*.java /home/hadoop/hadoop-3.1.2-src/hadoop-hdfs-project/hadoop-hdfs/src/main/java/org/apache/hadoop/hdfs/server/blockmanagement/
sh ~/mvnHadoopSrc.sh

for i in {5..6};do ssh hadoop@n$i "hdfs --daemon stop datanode";done
for i in {5..7};do ssh hadoop@n$i "hdfs --daemon stop datanode";done

# 查看每个节点的上下行已使用的带宽
ifstat -t -i ens9 1 1
ifstat -t -i ib0
ifstat -t -i ib0 1 1

for i in {1..19};do ssh hadoop@n$i "hostname;sudo ~/wondershaper/wondershaper -c -a ens9 &";done

scp -P 12345 -r ./0.9 hadoop@210.45.114.30:/home/hadoop/
scp -P 12345 ./argsTest.sh hadoop@210.45.114.30:/home/hadoop/

for i in {1..30};do ssh hadoop@node$i "hostname;sudo systemctl stop firewalld.service;sudo systemctl disable firewalld.service;sudo firewall-cmd --state";done

for i in {2..30};do scp ./workers hadoop@node$i:/home/hadoop/echadoop/hadoop-3.1.2/etc/hadoop/;done

for i in {1..30};do ssh hadoop@node$i "hostname;jps";done

# 让Simulate可用的JVM的内存大小从32m到450G
java -Xms32m -Xmx460800m Simulate

# 统计当前目录下文件的个数（不包括目录）
ls -l | grep "^-" | wc -l
# 统计当前目录下文件的个数（包括子目录）
ls -lR| grep "^-" | wc -l
# 查看某目录下文件夹(目录)的个数（包括子目录）
ls -lR | grep "^d" | wc -l

# 查看centos的版本
cat /etc/redhat-release
```

### 统计字符出现的次数
```sh
# vim
:%s/objStr//gn

# grep, 单个字符串
grep -o objStr  filename|wc -l
# grep, 多个字符串
grep -o ‘objStr1\|objStr2'  filename|wc -l  #直接用\| 链接起来即可
```
### Linux查找文件或内容
```sh
# 在一个目录下的所有文件中查找文件名
# 例如：将当前目录及其子目录下所有文件后缀为 .c 的文件列出来
find . -name "*.c"
# 在一个目录下的所有文件（内容）中查找字符串
find . -iname '*.conf' | xargs grep "search string" -sl
```
[参数解释-找内容](https://blog.51cto.com/u_15239532/2835499)
[参数解释-找文件名](https://www.runoob.com/linux/linux-comm-find.html)

### 查找文件
https://www.cnblogs.com/wuchanming/p/4013517.html

### Linux端口related
```sh
# 范围：0~65535，0~1023被OS使用
# 显示所有端口和所有对应的程序
netstat -atulnp | grep [port no]
# 查看某一端口的占用情况
sudo lsof -i:[port no]
# 清除端口占用
sudo kill -9 $(lsof -i:端口号 -t)
```

### CGroup
```sh
# 限速目录
/sys/fs/cgroup/blkio
blkio.throttle.read_bps_device
blkio.throttle.read_iops_device
blkio.throttle.write_bps_device
blkio.throttle.write_iops_device
"8:16 52428800" > blkio.throttle.read_bps_device

# bash按行读文件
while read line;do echo $line;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt

# cgroup磁盘限速
while read line;do echo $line >> blkio.throttle.read_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt
while read line;do echo $line >> blkio.throttle.write_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restrictions.txt
# 取消限速
while read line;do echo $line >> blkio.throttle.read_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restore.txt
while read line;do echo $line >> blkio.throttle.write_bps_device;done < /home/hadoop/raid2pp/parsingdisks/restore.txt

# 查看ib
for i in {1..19};do ssh hadoop@n$i "hostname;ifstat -t -i ib0 1 1";done
```

### CentOS防火墙
```sh
# 查看防火墙状态
firewall-cmd --state
# 停止firewall
systemctl stop firewalld.service
# 禁止firewall开机启动
systemctl disable firewalld.service 
```

### 高效的Vi的命令

```sh
# 跳转指定行
:rowNum

# 行首 & 行位
shift+4 & shift+6
```

### Git

```sh
# fatal: remote origin already exists
git remote rm origin
git remote add origin git@github.com:FBing/java-code-generator

# 放弃修改，强制覆盖本地代码
git fetch --all
git reset --hard origin/master 
git pull
```

### Kernel version and transparent huge page configuration

```sh
# 开启透明大页
echo 'always' > /sys/kernel/mm/transparent_hugepage/enabled
# 关闭透明大页
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled

# 查看大页使用情况
# 系统级
cat /proc/meminfo | grep AnonHugePages
# 进程级
cat /proc/[$PID]/smaps | grep AnonHugePages

# 查看cpu core的信息
numactl --hardware
```

## Crail

```sh
# 编译
rm -rf /home/hadoop/incubator-crail/assembly/target/apache-crail-1.3-incubating-SNAPSHOT-bin
mvn -DskipTests install

crail iobench -t write -s 2801664 -k 1 -m false -f /dc118836v2dbe7d36cb3540033blobsd759867d

crail iobench -t write -s 2342912 -k 1 -m false -f /260f35e1v248deada7a65747a0blobse23bc03c

crail iobench -t write -s 2670592 -k 1 -m false -f /dc118836v2f9ac28b0b2ec79aablobse90f9c2d

crail iobench -t write -s 117964800 -k 1 -m false -f /786b3803v2987f5d81ad3ea282blobs99686f6f

# iobench
crail iobench -t write -s $((1024*1024)) -k 1000
crail iobench -t write -s $((1024*1024)) -k 1 -m false -f /tmp.dat
crail iobench -t writeReplicas -s $((1024*1024)) -k 1 -m false -f /tmp.dat
crail iobench -t write -s $((1024*1024)) -k 1 -m false -f /tmp.dat
crail iobench -t readReplicas -k 1000 -f /tmp.dat

crail iobench -t writeECCache -s $((1024*1024)) -r $((256*1024)) -k 1000 -f /tmp.dat
crail iobench -t readSequential -s $((1024*1024)) -k 1000 -m false -f /tmp.dat

crail iobench -t readNormalErasureCoding -k 1000 -f /tmp.dat
crail iobench -t degradeReadReplicas -k 1 -f /tmp.dat
crail iobench -t recoveryReplicas -k 1 -f /tmp.dat

crail iobench -t degradeReadErasureCoding -k 1 -f /tmp.dat
crail iobench -t normalRecoveryErasureCoding -k 1 -f /tmp.dat
crail iobench -t pipelineDegradeReadErasureCoding -k 1 -f /tmp.dat -n $((64*1024))
crail iobench -t recoveryPipelineErasureCoding -k 1 -f /tmp.dat -n $((64*1024))
crail iobench -t monECDegradeReadErasureCoding -k 1 -f /tmp.dat -a 64 -n $((64*1024))
crail iobench -t monECRecoveryErasureCoding -k 1 -f /tmp.dat -a 64 -n $((64*1024))
crail iobench -t pureMonECDegradeReadErasureCoding -k 1 -f /tmp.dat -a 64
crail iobench -t pureMonECRecoveryErasureCoding -k 1 -f /tmp.dat -a 64

ycsbTest(ycsbRequestType, size, encodingSplitSize, pureMonECSubStripeNum, transferSize, isPureMonEC);
user5464797676921564295
# ycsb test [replicasYCSB|eccacheYCSB|ecpipelineYCSB|pureMonECYCSB|monECYCSB]
crail iobench -t ycsbTest -y replicasYCSB -s $((1024*1024))
crail iobench -t ycsbTest -y eccacheYCSB -s $((1024*1024)) -r $((256*1024))
crail iobench -t ycsbTest -y ecpipelineYCSB -s $((1024*1024)) -r $((64*1024))
crail iobench -t ycsbTest -y pureMonECYCSB -s $((1024*1024)) -r $((256*1024)) -a 64 -i true
crail iobench -t ycsbTest -y monECYCSB -s $((1024*1024)) -n $((32*1024)) -a 64

# ECCache
crail iobench -t writeECPipeline -s $((6*256*1024)) -r $((256*1024)) -k 1500 -f /tmp1.dat
# 64k pipeline
crail iobench -t writeECPipeline -s $((6*256*1024)) -r $((64*1024)) -k 1500 -f /tmp2.dat 
# 4k pureMonEC
crail iobench -t writeECPipeline -s $((1024*1024)) -r $((256*1024)) -k 1 -f /tmp.dat -a 64 -i true
# 4k MonEC
crail iobench -t writeMicroEC -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t multiWriteMicroEC -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_slicing -s $((1024*1024)) -k 1500 -a 64 -n $((256*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncFixed -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_asyncNotFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat

taskset -c 11 crail iobench -t writeMicroEC_asyncFixed -s $((1024*1024)) -k 1500 -a 64 -n $((16*1024)) -f /tmp1.dat
taskset -c 11 crail iobench -t writeMicroEC_asyncFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
taskset -c 11 crail iobench -t writeMicroEC_asyncNotFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat

crail iobench -t testNativeEncoding -s $((1024*1024)) -k 1500
crail iobench -t testAsyncCodingSame -s $((16*1024)) -k 1500 -a 1
crail iobench -t testAsyncCodingSame -s $((6*256*1024)) -k 1500 -a 64
crail iobench -t testNativePureEncoding -s $((6*64*1024)) -k 1500 
crail iobench -t testNativePureEncoding -s $((6*256*1024)) -k 1500 
crail iobench -t testNativePureEncoding -s $((6*256*1024)) -k 1500 -a 64 -i true
crail iobench -t testNetworkLatency -s $((6*256*1024)) -k 1500 -f /n1.dat


crail iobench -t writeMicroEC_CodingFixed -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_CodingFinished -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
crail iobench -t writeMicroEC_CodingDescent -s $((3*256*1024)) -k 1500 -a 64 -f /tmp3.dat
crail iobench -t writeMicroEC_CodingDescentRegenerated -s $((1024*1024)) -k 1500 -a 64 -n $((4*1024)) -f /tmp1.dat
for i in {1..17};do crail iobench -t writeMicroEC -s $((1024*1024)) -k 10000 -a 64 -n $((16*1024)) -f /tmp${i}.dat;done

crail iobench -t warmupCreateRedundantFile -k 1500 -f /w1.dat

# shell
$CRAIL_HOME/bin/crail fs
$CRAIL_HOME/bin/crail fs -ls <crail_path>
$CRAIL_HOME/bin/crail fs -mkdir <crail_path>
$CRAIL_HOME/bin/crail fs -copyFromLocal <local_path> <crail_path>
$CRAIL_HOME/bin/crail fs -copyToLocal <crail_path> <local_path>
$CRAIL_HOME/bin/crail fs -cat <crail_path>

# 常用脚本
for i in {2..9};do scp -r /home/hadoop/incubator-crail/assembly/target/apache-crail-1.3-incubating-SNAPSHOT-bin/apache-crail-1.3-incubating-SNAPSHOT hadoop@worker$i:~/;done
for i in {2..9};do ssh hadoop@worker$i "hostname;rm /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/logs/*;rm -rf /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/tmp/*";done

# test ib
for i in {2..9};do ssh hadoop@node$i "hostname;ifstat -t -i ib0 1 1";done

# node2
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/core-site.xml hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/crail-site.conf hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for j in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/slaves hadoop@node$j:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/;done
for i in {3..9};do scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/* hadoop@node$i:/home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/;done

scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/core-site.xml hadoop@node1:/home/hadoop/incubator-crail/conf/
scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/crail-site.conf hadoop@node1:/home/hadoop/incubator-crail/conf/
scp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/conf/slaves hadoop@node1:/home/hadoop/incubator-crail/conf/

for i in {2..5};do ssh hadoop@node$i "hostname;sudo cp /home/hadoop/apache-crail-1.3-incubating-SNAPSHOT/lib/libjnitest.so /usr/lib64/";done
for i in {2..5};do ssh hadoop@node$i "hostname;sudo rm /lib64/libjnitest.so";done
```

## 统计代码行数
git统计的不准确

## 创建Linux新账户

```sh
# pm集群
# useradd -d  /home/ecgroup -m ecgroup -s /bin/bash
# 配置账号密码
# passwd ecgroup
# 在/etc/sudoers配置一行，使得sudo su时不需要输入密码
# 创建~/.ssh并拷贝已有公私钥，authorized_keys，known_hosts，并更改文件所属文件组
# chmod ~/.ssh
# chown -R ecgroup:ecgroup ~/.ssh
```

## Swap

```sh
# 不重启电脑，禁用启用swap，立刻生效
# 禁用命令
sudo swapoff -a
# 启用命令
sudo swapon -a
# 查看是否关闭swap，显示0则表示关闭成功
sudo free -m
```

## 时间戳（C/C++）
```C
// 头文件
#include <time.h>
// 初始化两个变量
struct timespec time1 = {0, 0};
struct timespec time2 = {0, 0};
// 获得第一个时间戳
clock_gettime(CLOCK_REALTIME, &time1);
// 需要测试内容
// 获得第二个时间戳
clock_gettime(CLOCK_REALTIME, &time2);
// 计算时间，单位为ns
long encode_time=(time2.tv_sec-time1.tv_sec)*1000000000+(time2.tv_nsec-time1.tv_nsec);
```