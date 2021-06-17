

## Mounting Vector's remote filesystem to your local linux filesystem

First, you will need to change **Vector's SSHD deamon configuration**, to make SFTP working.

- Follow this [guide](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/vector-sftp.md) to do just that.

Remember, that after updating the the Vector's software / OS / doing factory reset, these changes will be lost and you will need to do this step again.

## Mount Vector's filesystem with *SSHFS*

1. Install sshfs to your linux

`sudo apt install -y sshfs`

2. Create target mount point:

`sudo mkdir /mnt/vector-XXXX/`


### A) Mounting with FSTAB

1. Append the following line to `/etc/fstab`

- To edit the file for example in *nano* editor, use `sudo nano /etc/fstab`
- Append following line and save the file

```
sshfs#root@192.168.xxx.xxx:/ /mnt/vector-XXXX      fuse    user,_netdev,auto_cache,reconnect,uid=1000,gid=1000,IdentityFile=/full/path/to/.ssh/id_rsa_Vector-XXXX,idmap=user,allow_other,transform_symlinks,follow_symlinks    0       2
```

2) To finally mount the Vector's filesystem do just:

`sudo mount /mnt/vector-XXXX`


### B) Mounting directly with SSHFS

Use the following command to mount:

```
sudo sshfs -o allow_other,default_permissions,transform_symlinks,follow_symlinks,IdentityFile=/full/path/to/.ssh/id_rsa_Vector-XXXX root@192.168.xxx.xxx:/ /mnt/vector-XXXX/`
```
(or when using the [ssh alias](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/vector-ssh_alias.md) call just

`sudo sshfs -o allow_other,default_permissions,transform_symlinks,follow_symlinks Vector-XXXX:/ /mnt/vector-XXXX/`)


Other usefull switches that may improve the speed and performance are *nolocalcaches*, *no_readahead*


## Unmounting

To unmount the Vector's filesystem use:

`sudo umount /mnt/vector-XXXX`

