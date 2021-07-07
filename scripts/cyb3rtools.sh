#!/bin/bash
set -u

abort() {
  echo "$1 Aborting..."
  exit 1
}

# perform basic checks

if ! command -v curl > /dev/null ; then
  abort "You must install cURL before using this script."
fi

if ! uname -a | grep -q "armv7l" ; then
  abort "This is not Vector! This script is intended only for armv7l devices."
fi

ROOT_MOUNT=$(mount | grep -q "on / type ext4")
if ! echo $ROOT_MOUNT | grep -q "rw," ; then
  echo "Remounting / to rw"
  mount -o remount,rw /
fi

# SETUP
: ${DIALOG=dialog}

: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

: ${SIG_NONE=0}
: ${SIG_HUP=1}
: ${SIG_INT=2}
: ${SIG_QUIT=3}
: ${SIG_KILL=9}
: ${SIG_TERM=15}

BASE_URL=https://raw.githubusercontent.com/cyb3rdog/vector-oskr-notes/main
DIALOG_RESULT=0
tempfile=`(tempfile) 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 $SIG_NONE $SIG_HUP $SIG_INT $SIG_QUIT $SIG_TERM

export NCURSES_NO_UTF8_ACS=1

install_package() {
  COMMAND="/bin/bash -c 'curl -fsSL "$BASE_URL"/packages/"$1".tar.gz | tar -xzC /'"
  if uname -a | grep -q "armv7l" ; then
    eval $COMMAND
  fi
}

# PREREQUISITES
if ! command -v dialog > /dev/null ; then
  install_package 'dialog'
fi

# WELCOME

$DIALOG --title " Cyb3rTools " --clear "$@" --msgbox \
"Welcome to Cyb3rTools for OSKR!\n\n \
This interface will allow you to install additional tools, software \
and use some of the most frequently used features of your OSKR Vector.\n\n \
Goal of this project is to consolidate as much tools, scripts, \
and software into one place as possible.\nContributions wanted!\n\nEnjoy!" 15 65
dialog_result $?

dialog_quit() {
  "$DIALOG" --clear --title " Cyb3rTools " --yesno "\n         Do you really want to quit?" 7 50
  case $? in
    $DIALOG_OK)
      DIALOG_RESULT=1
      clear
      exit 0;;
    $DIALOG_CANCEL)
      DIALOG_RESULT=99;;
  esac
}

dialog_result() {
  DIALOG_RESULT=$1
  case $DIALOG_RESULT in
    $DIALOG_OK)
      DIALOG_RESULT=`cat $tempfile`;;
    $DIALOG_CANCEL)
      DIALOG_RESULT=1;;
    $DIALOG_ESC)
      DIALOG_RESULT=1;;
    $DIALOG_HELP)
      echo "Help pressed.";;
    $DIALOG_EXTRA)
      echo "Extra button pressed.";;
    $DIALOG_ITEM_HELP)
      echo "Item-help button pressed.";;
  esac
}

process() {
  (echo 50;cat <<XXX
$($1)
XXX
echo 100;sleep 0.6) | \
  $DIALOG --title " Cyb3rTools " --gauge "\n$2" 8 65 0
}

# SUB MENUS

menu_install() {
  $DIALOG --clear --title " Cyb3rTools Install Menu " "$@" --menu \
    "\nSelect a package to install:\n " 15 65 6 \
    "APT" "The apt, apt-get and dpkg software" \
    "HTOP" "The htop process monitor" \
    "TMUX" "Terminal multiplexer" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    "1")
      DIALOG_RESULT=99;;
    "APT")
      item_install apt
      clear
      echo "Processing initial installation, this may take a while..."
      echo "Please wait..."
      echo ""
      ldconfig
      apt-get update
      apt-get -f -y --force-yes install
      ;;
    "HTOP")
      item_install htop;;
    "TMUX")
      item_install tmux;;
    "SSHFS")
      item_install sshfs;;
    "FEATURES")
      item_install mc;;
  esac
  
  if [ $DIALOG_RESULT != 99 ];
  then
    menu_install
  fi
}

item_install() {
  process "install_package $1" "Installing package '$1'. Please wait..."
  menu_install
}

menu_features() {
 $DIALOG --clear --title " Cyb3rTools Features Menu " "$@" --menu \
    "\nSelect an option:\n " 15 65 6 \
    "RESTART" "Restarts the Vector" \
    "STOP SERVICES" "Stops the anki-robot.target services" \
    "START SERVICES" "Starts the anki-robot.target services" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    "1")
      DIALOG_RESULT=99;;
    "RESTART")
      process "/sbin/reboot" "Restarting Vector..."
      exit 0;;
    "STOP SERVICES")
      process "systemctl stop anki-robot.target" "Stopping anki-robot.target";menu_features;;
    "START SERVICES")
      process "systemctl start anki-robot.target" "Starting anki-robot.target";menu_features;;
  esac
}


# MAIN MENU

while test $DIALOG_RESULT != "1"
do

  $DIALOG --clear --title " Cyb3rTools Main Menu " "$@" --menu \
    "\nSelect an option:\n " 20 65 6 \
    "INSTALL" "Install additional packages" \
    "SCRIPTS" "Run various scripts" \
    "STATISTICS" "Take a look at Vectors stats" \
    "FEATURES" "Use some integrated features" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    $DIALOG_CANCEL)
      dialog_quit;;
    $DIALOG_ESC)
      dialog_quit;;
    "INSTALL")
      menu_install;;
    "SCRIPTS")
      menu_scripts;;
    "STATISTICS")
      menu_stats;;
    "FEATURES")
      menu_features;;
  esac

done
