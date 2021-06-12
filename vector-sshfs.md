

# Creating an SSH Alias, to simlify the use of the Identity file:

1. Copy your ssh private key (id_rsa_Vector-XXXX) file over to your linux to ~/.ssh/

2. Create an ssh alias for your Vector, in this example I am using `Vector-XXXX`
(To edit the file in *nano* editor, use `nano ~/.ssh/config`)

```
Host Vector-XXXX
    HostName 192.168.xxx.xxx
    User root
    IdentityFIle ~/.ssh/id_rsa_Vector-XXXX
```

Now, you can use this new `Vector-XXXX` alias for any ssh tools.

Examples:

`ssh Vector-XXXX`

`ssh Vector-XXXX mount -o remount,rw /`

`scp /local/file Vector-XXXX:/remote/file`


# Mounting Vector's remote filesystem to your local linux filesystem


## Change Vector's sshd deamon configuration

1. SSH to Vector

`ssh root@192.168.xxx.xxx` (or when using an alias jsut `ssh Vector-XXXX`)

2. Make Vector's root fs writeable:

`mount -o remount,rw /`

change the sftp subsystem from openssh server to internal sftp in `sshd_config`:
(To edit the file in *nano* editor, use `sudo nano /etc/ssh/sshd_config`)

```
#Subsystem sftp /usr/lib/openssh/sftp-server
Subsystem sftp internal-sftp
```

3. Exit the ssh session

`exit` or `logout`

4. Reboot your Vector:

`ssh Vector-XXXX /sbin/reboot`


## Mount Vector's filesystem with *`SSHFS`*

1. Install sshfs

`sudo apt install -y sshfs`

2. Create target mount point:

`sudo mkdir /mnt/vector-XXXX/`


### A) Mounting with FSTAB 

1. Append the following line to `/etc/fstab`

(To edit the file in *nano* editor, use `sudo nano /etc/fstab`)

```
sshfs#root@192.168.xxx.xxx:/ /mnt/vector-XXXX      fuse    user,_netdev,auto_cache,reconnect,uid=1000,gid=1000,IdentityFile=/full/path/to/.ssh/id_rsa_Vector-XXXX,idmap=user,allow_other,transform_symlinks,follow_symlinks    0       2
```

2) To Mount the Vector's filesystem do:

`sudo mount /mnt/vector-XXXX`


### B) Mounting directly with SSHFS

Use either of the following commands to mount:

```
sudo sshfs -o allow_other,default_permissions,transform_symlinks,follow_symlinks,IdentityFile=/full/path/to/.ssh/id_rsa_Vector-XXXX root@192.168.xxx.xxx:/ /mnt/vector-XXXX/`
```
(or when using an ssh alias just `sudo sshfs -o allow_other,default_permissions,transform_symlinks,follow_symlinks vector-XXXX:/ /mnt/vector-XXXX/`)


Other usefull switches that may improve the speed are *nolocalcaches*, *no_readahead*


## Unmount

To unmount the Vector's filesystem use:

`sudo umount /mnt/vector-XXXX`


