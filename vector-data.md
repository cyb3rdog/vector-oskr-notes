
## Backing up whole userdata parion over the ssh:

```
ssh root@192.168.xxx.xxx "dd if=/dev/block/bootdevice/by-name/userdata | gzip -1 -" | dd of=./userdata.img.gz status=progress
```
(or when using an [ssh alias](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/vector-ssh_alias.md) just

```ssh Vector-XXXX "dd if=/dev/block/bootdevice/by-name/userdata | gzip -1 -" | dd of=./userdata.img.gz status=progress```


### Mounting Vector's userdata partion backup file to your local linux filesystem

- Extract the userdata.img:	```gzip -d -v ./userdata.img.gz```
- Download encryption key:	```ssh root@192.168.xxx.xxx user-data-locker > ./userdata.key```
- Encrypt and load userdata:	```sudo cryptsetup -q --key-file ./userdata.key luksOpen ./userdata.img userdata```
- Create target mountpoint:	```sydo mkdir -p /mnt/userdata```
- Mount the userdata device:	```sudo mount -o rw,nosuid,nodev,noatime,data=ordered /dev/mapper/userdata /mnt/userdata```


### Unmounting UserData

- ```sudo umount /mnt/userdata```
- ```sudo cryptsetup luksClose userdata```

The [mount_userdata.sh](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/scripts/mount_userdata.sh) script does all of this,
it downloads the partition to local filesystem, copy the encyption file, open and mount it.


## Restoring the user data partion

You can either copy the whole partition back, or just copy the selected files over to Vector.

- Stop the robot.target:	```systemctl stop anki-robot.target```
- Copy the selected files or the whole partion back. This command copies the whole partition without:
```
dd if=./userdata.img | ssh root@192.168.xxx.xxx "dd of=/dev/block/bootdevice/by-name/userdata"
```
- Start the robot.target:	```systemctl start anki-robot.target```
