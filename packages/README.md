
## Cyb3rTools - A collection of software, scripts, and tools for Vector's OS.

I like to simplify my life with tools I am used to. Here are the most frequently used,
nicely packed into the friendly user environment, with some additional features.

## Install

- ### 1. SSH to your Vector 
```sh
ssh root@XX.XX.XX.XX -i <path/to/key>
```

- ### 2. Go for it!
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/scripts/cyb3rtools.sh)"
```

In the Cyb3rTools Main menu, select an *Install* option to install selected packages:

![image](https://user-images.githubusercontent.com/12493945/124916998-97b1f000-dff3-11eb-869a-5743614bf9da.png)


## Individual packages 

You can also use following shell commands to install selected packages to your OSKR unlocked Vector robot individually:

### Apt & dpkg

- *``` available only through Cyb3rTools ```*

### Dialog
```sh
/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/packages/dialog.tar.gz | tar -xzC /"
```
### Sshfs
```sh
/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/packages/sshfs.tar.gz | tar -xzC /"
```
### Squashfs
```sh
/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/packages/squashfs.tar.gz | tar -xzC /"
```
### Htop
```sh
/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/packages/htop.tar.gz | tar -xzC /"
```
### Tmux
```sh
/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main/packages/tmux.tar.gz | tar -xzC /"
```


### [Back to main page](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/README.md)  