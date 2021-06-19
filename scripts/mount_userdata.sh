#!/bin/bash

SSH_OPTIONS="root@XX.XX.XX.XX -i <path/to/key>"

WORKING_DIR="./userdata"
#MOUNT_POINT=/mnt/userdata
MOUNT_POINT=$WORKING_DIR/data
MOUNT_OPTIONS="defaults,nosuid,nodev,noatime"
USER_DATA_IMG="userdata.img"
KEY_FILE="userdata.key"
ROBOT_KEY="robot.pem"

echo "=== VECTOR's USERDATA MOUNT SCRIPT ==="
echo

if [ "$SSH_OPTIONS" = "root@XX.XX.XX.XX -i <path/to/key>" ]; then
  echo "Please change the 'SSH_OPTION' variable first!"
  exit 0
fi

# Check the prerequisites
if ! command -v cryptsetup > /dev/null ; then
  echo "Installing cryptsetup..."
  sudo apt install -y cryptsetup
fi

# Check the working dir
if [ ! -d $WORKING_DIR ]; then
  echo "- Creating Working dir..."
  mkdir -p $WORKING_DIR
fi

# Check the robot private key
if [ ! -f $WORKING_DIR/$ROBOT_KEY ]; then
  echo "- Getting Rotot private key..."
  ssh $SSH_OPTIONS cat /data/etc/robot.pem > $WORKING_DIR/$ROBOT_KEY
  chmod 440 $WORKING_DIR/$ROBOT_KEY
fi

# Check the userdata key file
if [ ! -f $WORKING_DIR/$KEY_FILE ]; then
  echo "- Getting userdata key file..."
  ssh $SSH_OPTIONS user-data-locker > $WORKING_DIR/$KEY_FILE
fi

# Check the userdata.img
if [ ! -f $WORKING_DIR/$USER_DATA_IMG ]; then
  echo "- Downloading userdata partition..."
  ssh $SSH_OPTIONS "dd if=/dev/block/bootdevice/by-name/userdata | gzip -1 -" | dd of=$WORKING_DIR/$USER_DATA_IMG.gz status=progress
  echo "- Extracting userdata..."
  CURRENT_DIR=$(pwd)
  cd $WORKING_DIR
  gzip -d -v $USER_DATA_IMG.gz
  cd $CURRENT_DIR
fi

# Check the mount point
if [ ! -d $MOUNT_POINT ]; then
  echo "- Creating mounting point..."
  sudo mkdir -p $MOUNT_POINT
fi

# Opening the encrypted userdata
echo "- Opening and decrypting userdata..."
DISK_UUID=/dev/disk/by-id/dm-uuid-*$(cryptsetup luksUUID $WORKING_DIR/$USER_DATA_IMG | tr -d -)*
if [ ! -b $DISK_UUID ]; then
  sudo cryptsetup -q --key-file $WORKING_DIR/$KEY_FILE luksOpen $WORKING_DIR/$USER_DATA_IMG userdata
else
  echo "Already openned: '$DISK_UUID'"
fi

# Mount the user data
echo "- Mounting userdata to $MOUNT_POINT"
MOUNT_DEV=$(df -P $MOUNT_POINT | tail -1 | cut -d' ' -f 1)
if [ "$MOUNT_DEV" = "/dev/mapper/userdata" ]; then
  echo "Already mounted: '$MOUNT_DEV'";
else
  sudo mount -o $MOUNT_OPTIONS --source /dev/mapper/userdata --target $MOUNT_POINT
fi

echo "- All done."
echo " You can browse and modify userdata as root."
echo " Once you will finish your changes unmount using:"
echo $(tput bold)
echo "sudo umount $MOUNT_POINT"
echo "sudo cryptsetup luksClose userdata"
echo $(tput sgr0)
