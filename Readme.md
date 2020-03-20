## Linux相关

### 挂载磁盘相关命令
```sh
# 查看所有磁盘的顺序及类型
lsscsi

# 查看当前已挂载的磁盘
df -h

# 对已有数据的磁盘重新进行挂载
sudo mount /dev/sdj1(磁盘文件路径) /mnt/hadoop(挂载文件夹路径)

# 添加开机自动挂载硬盘时要以UUID的方式，不要用绝对路径的方式，因为硬盘再每次启动后顺序可能会变
# 查看UUID
sudo blkid
# 注意：每次重建文件系统（格式化等），UUID都会变

# 添加开机自动挂载
sudo vi /etc/fstab
UUID=5c3dcf06-b781-4f5b-8542-3077be342814 /mnt/hadoop ext4 defaults 0 0

# 查看可挂载的磁盘都有哪些
sudo fdisk -l
```

