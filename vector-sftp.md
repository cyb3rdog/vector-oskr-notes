
## Change Vector's sshd deamon *sftp* configuration

By enabling the SFTP, you can use various tools to get convenient access to Vector's filesystem

1. SSH to Vector

`ssh root@192.168.xxx.xxx` (or when using an alias jsut `ssh Vector-XXXX`)

2. Make Vector's root fs writeable:

`mount -o remount,rw /`

Change the sftp subsystem from openssh server to internal sftp in `sshd_config`:
(To edit the file in *nano* editor, use `sudo nano /etc/ssh/sshd_config`)

- Find the line starting with *Subsytem* and comment it out by inserting `#` in front
- Append new line `Subsystem sftp internal-sftp`

Result should look like this

```
#Subsystem sftp /usr/lib/openssh/sftp-server
Subsystem sftp internal-sftp
```

3. Reboot your Vector:

Do this either locally from Vector when ssh'd, by calling `/sbin/reboot`, or from remote system by first logging out from the ssh with `exit` or `logout`.

Then call reboot remotely:

`ssh root@192.168.xxx.xxx /sbin/reboot`


