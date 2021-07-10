#!/bin/bash
set -u

abort() {
  echo "$1 Aborting..."
  exit 1
}

# === BASIC CHECKS ===
if ! command -v curl > /dev/null ; then
  abort "You must install cURL before using this script."
fi

if ! uname -a | grep -q "armv7l" ; then
  abort "This is not Vector! This script is intended only for armv7l devices."
fi

ROOT_MOUNT=$(mount | grep "on / type ext4")
if ! echo $ROOT_MOUNT | grep -q "rw," ; then
  echo "Remounting / to rw"
  mount -o remount,rw /
fi

# === FAIL-SAFE ===
if [ ! -d "/home/root/.ssh" ]; then
  mkdir -p /home/root/.ssh
fi
cp /data/ssh/authorized_keys /home/root/.ssh/

# === SETUP ===
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

# === WELCOME ===

$DIALOG --title " Cyb3rTools (preview version) " --clear "$@" --msgbox \
"Welcome to Cyb3rTools for OSKR!\n\n \
This interface will allow you to install additional tools, software \
and use some of the most frequently used features of your OSKR Vector.\n\n \
Goal of this project is to consolidate as much tools, scripts, \
and software into one place as possible.\nContributions wanted!\n\n\
Disclaimer: USE AT YOUR OWN RISK!\n\nEnjoy!" 17 65

# === FUNCTIONS ===

get_max_width() {
  MAX_WIDTH=$(/usr/bin/tput cols)
  if [ -z "$MAX_WIDTH" ]; then
    MAX_WIDTH=79
  fi
  if [ $MAX_WIDTH \> 200 ]; then
    MAX_WIDTH=200
  fi
  MAX_WIDTH=$(expr $MAX_WIDTH - 12)
}

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

install_package() {
  COMMAND="/bin/bash -c 'curl -fsSL "$BASE_URL"/packages/"$1".tar.gz | tar -xzC /'"
  if uname -a | grep -q "armv7l" ; then
    eval $COMMAND
  fi
}

# === PREREQUISITES ===

if ! command -v dialog > /dev/null ; then
  echo "Installing prerequisites. Please wait..."
  install_package 'dialog'
fi

# === MENU INSTALL ===

menu_install() {
  $DIALOG --clear --title " Cyb3rTools Install Menu " "$@" --menu \
    "\nSelect a package to install:\n " 19 65 8 \
    "APT" "The apt, apt-get and dpkg software" \
    "SSHFS" "The fuse + sshfs packages" \
    "SQUASFS" "Squashfs-tools package" \
    "PARTED" "Disk partition manipulator" \
    "E2FSPROGS" "File system utilities" \
    "HTOP" "The htop process monitor" \
    "TMUX" "Terminal multiplexer" \
    "MC" "Midnight commander" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    "1")
      DIALOG_RESULT=99
      return;;
    "APT")
      item_install apt
      clear
      echo "Processing initial installation, this may take a while..."
      echo "Please wait..."
      echo ""
      apt-get update
      apt-get -f -y --force-yes install
      ldconfig
      apt-get -f -y --force-yes install
      ldconfig
      ;;
    "HTOP")
      item_install htop;;
    "SSHFS")
      item_install sshfs;;
    "SQUASFS")
      item_install squashfs;;
    "PARTED")
      item_install parted;;
    "E2FSPROGS")
      item_install e2fsprogs;;
    "TMUX")
      item_install tmux;;
    "SSHFS")
      item_install sshfs;;
    "MC")
      item_install mc;;
  esac

  menu_install
}

item_install() {
  process "install_package $1" "Installing package '$1'. Please wait..."
}

# MENU STATS

menu_stats() {
 $DIALOG --clear --title " Cyb3rTools Stats Menu " "$@" --menu \
    "\nSelect an option:\n " 15 65 4 \
    "SYSINFO" "Displays the system info" \
    "MESSAGES" "Tail the messages log" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    "1")
      DIALOG_RESULT=99
      return;;
    "MESSAGES")
      get_max_width
      $DIALOG --title " Messages " --tailbox /var/log/messages 20 $MAX_WIDTH;;
    "SYSINFO")
      stats_sysinfo;;
  esac

  menu_stats
}

stats_sysinfo() {

  PREV_TOTAL=0
  PREV_IDLE=0
  DIALOG_RESULT=0
  while test $DIALOG_RESULT != "1"
  do
    cpuTempC=""
    cpuTempF=""
    if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
      cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp))) && cpuTempF=$((cpuTempC*9/5+32))
    fi

    CPU=(`sed -n 's/^cpu\s//p' /proc/stat`)
    IDLE=${CPU[3]} # Just the idle CPU time.
    TOTAL=0
    for VALUE in "${CPU[@]}"; do
      let "TOTAL=$TOTAL+$VALUE"
    done
    let "DIFF_IDLE=$IDLE-$PREV_IDLE"
    let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
    let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL)/10"
    let "DIFF_USAGEM=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL)-($DIFF_USAGE*10)"

    PREV_TOTAL="$TOTAL"
    PREV_IDLE="$IDLE"

    cpufreq=$(</sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    cpumodel=$(cat /proc/cpuinfo | grep 'model name' | uniq | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
    sdcard1=`df -h |head -3|grep -v 'none'|grep -v 'tmpfs'|awk '{print $0}'`
    memtotal=$(free | grep Mem | awk '{printf "%0.0fM",$2/1024}')
    memused=$(free | grep Mem | awk '{printf "%0.0fM",$3/1024}')
    
    local upSeconds="$(cut -d. -f1 /proc/uptime)"
    local secs=$((upSeconds%60))
    local mins=$((upSeconds/60%60))
    local hours=$((upSeconds/3600%24))
    local days=$((upSeconds/86400))
    local UPTIME=$(printf "%d days, %02d:%02d:%02d" "$days" "$hours" "$mins" "$secs")    

    infobox=""
    infobox="${infobox}\n$(date +"%A,%e %B %Y, %r")\n"
    infobox="${infobox}Uptime: ${UPTIME}\n"
    infobox="${infobox}$cpumodel @ $((cpufreq/1000)) MHz\n"
    infobox="${infobox}$(uname -srmo)\n\n"
    infobox="${infobox}${sdcard1}\n\n"
    infobox="${infobox}CPU Usage:            $DIFF_USAGE.$DIFF_USAGEM% ($(ps ax | wc -l | tr -d " ") processes)\n"
    infobox="${infobox}CPU Mem:              $memused used / $memtotal total\n"
    infobox="${infobox}CPU Temp:             ${cpuTempC}°C / ${cpuTempF}°F\n"
    infobox="${infobox}IP Address:           $(ip route get 8.8.8.8 2>/dev/null | awk '{print $NF; exit}')\n"
    $DIALOG --title " $(hostname) System Information " --pause "${infobox}" 21 70 0
    dialog_result $?

  done
}

# === MENU FEATURES ===

menu_features() {
 $DIALOG --clear --title " Cyb3rTools Features Menu " "$@" --menu \
    "\nSelect an option:\n " 15 65 4 \
    "REBOOT" "Reboot the Vector" \
    "STOP SERVICES" "Stops the anki-robot.target services" \
    "START SERVICES" "Starts the anki-robot.target services" \
    2> $tempfile
  dialog_result $?

  case $DIALOG_RESULT in
    "1")
      DIALOG_RESULT=99;;
    "REBOOT")
      process "/sbin/reboot" "Rebooting Vector..."
      exit 0;;
    "STOP SERVICES")
      process "systemctl stop anki-robot.target" "Stopping anki-robot.target";menu_features;;
    "START SERVICES")
      process "systemctl start anki-robot.target" "Starting anki-robot.target";menu_features;;
  esac
}

# === MAIN MENU ===

while test $DIALOG_RESULT != "1"
do

  $DIALOG --clear --title " Cyb3rTools Main Menu " "$@" --menu \
    "\nSelect an option:\n " 15 65 4 \
    "INSTALL" "Install additional packages" \
    "SCRIPTS" "--- to be added ---" \
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
