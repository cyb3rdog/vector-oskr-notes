
## Creating an SSH Alias, to simlify the use of the RSA Identity file:

By creating the ssh alias, you will no longer need to specify the user, ip adress and the path to the identity file with all ssh related tools


1. Copy your ssh private key (id_rsa_Vector-XXXX) file over to your linux to ~/.ssh/

2. Create an ssh alias for your Vector, in this example I am using `Vector-XXXX`
(To edit the file in *nano* editor, use `nano ~/.ssh/config`)

```
Host Vector-XXXX
    HostName 192.168.xxx.xxx
    User root
    IdentityFIle ~/.ssh/id_rsa_Vector-XXXX
```

3. Save and exit the text editor


Now, you can use this new `Vector-XXXX` alias for any ssh tools.

Examples:

`ssh Vector-XXXX`

`ssh Vector-XXXX mount -o remount,rw /`

`ssh Vector-XXXX /sbin/reboot`

`scp /local/file Vector-XXXX:/remote/file`


