#!/bin/bash

TMP_FOLDER=$(mktemp -d)
USERNAME='ebitsmn'
CONFIG_FILE='ebits.conf'
CONFIGFOLDER='/home/ebitsmn/.EBITS'
COIN_DAEMON='ebitsd'
COIN_CLI='ebits-cli'
COIN_PATH='/usr/local/bin/'
COIN_REPO='https://github.com/emeraldminingco/ebits'
COIN_TGZ='https://github.com/emeraldminingco/ebits/releases/download/0.17.2/Ebits0172Linux.zip'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='Ebits'
COIN_PORT=55350 #Updated Port
RPC_PORT=6480


NODEIP=$(curl -s4 icanhazip.com)


RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function ask_for_bootstrap() {

printf "Hello,  \n Enter 1 for Install Masternode \n Enter 2 for Update Masternode \n Enter 3 for bootstrap. \n "
read choice
if (($choice == 1 )) 
 then
	create_user
	cleanup_mess
	#checks
	prepare_system
	#ask_permission
	#if [[ "$ZOLDUR" == "YES" ]]; then
	#  download_node
	#else
		create_swap
		download_node
	#fi
	setup_node
	exit 
elif (($choice == 2 ))
 then
	create_user
	backup
	save_key
	cleanup_mess
	download_node
	get_ip
	restore_key
	enable_firewall
	configure_systemd
	blocks
	important_information
	echo -e "${GREEN}Masternode Updated.${NC}"
elif (($choice == 3 ))
 then
	backup
	blocks
else
	echo -e "No correct option selected."
	exit 1
fi
}
function cleanup_mess() {
	killall ebitsd
	sleep 11
	systemctl stop $COIN_NAME.service
	cd /
	rm -rf .EBITS
	rm ebits*
	rm -rf Ebits*
	rm setup*
	rm doge.txt*
	rm block*
	cd /$USERNAME
	rm -rf .EBITS
	rm ebits*
	rm -rf Ebits*
	rm setup*
	rm block*
	rm doge.txt*
	cd $COIN_PATH
	rm ebits*
	rm test_ebits
	rm block*
	cd /$USERNAME
}

function create_user() {

	if [ $(id -u) -eq 0 ]; then
		read -s -p "Enter password : " password
		egrep "^$USERNAME" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo "$USERNAME exists!"
		else
			pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
			useradd -m -p $pass $USERNAME
			[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
			usermod -aG sudo $USERNAME
		fi
	else
		echo "Only root may add a user to the system"
	fi
}

function compile_node() {
  echo -e "Prepare to compile $COIN_NAME"
  git clone $COIN_REPO $TMP_FOLDER >/dev/null 2>&1
  compile_error
  cd $TMP_FOLDER
  chmod +x ./autogen.sh 
  chmod +x ./share/genbuild.sh
  chmod +x ./src/leveldb/build_detect_platform
  ./autogen.sh
  compile_error
  ./configure
  compile_error
  make
  compile_error
  make install
  compile_error
  strip $COIN_PATH$COIN_DAEMON $COIN_PATH$COIN_CLI
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}
function download_node() {
  echo -e "Prepare to download ${GREEN}$COIN_NAME${NC}."
  cd ~ >/dev/null 2>&1
  rm -rf Ebits*
  cd $COIN_PATH
  rm -rf ebits*
  cd ~
  wget -q $COIN_TGZ
  compile_error
  apt-get install -y unzip
#   tar xvzf $COIN_ZIP -C $COIN_PATH >/dev/null 2>&1
unzip Ebits0172Linux.zip
cd Ebits0172Linux
chmod -R 775 *
cp * $COIN_PATH
cd ..
cd $COIN_PATH
chmod -R 775 *
cd ..
  cd - >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}

function blocks() {
	wget https://github.com/dogecash/dogecash/raw/master/blocks.sh
	chmod 777 blocks.sh 
	bash blocks.sh
	echo -e "Cleaning up Blocks.sh"
	rm blocks.sh
}
function ask_permission() {
 echo -e "${RED}I trust binaires and want to use$ $COIN_NAME binaries compiled on his server.${NC}."
 echo -e "Please type ${RED}YES${NC} if you want to use precompiled binaries, or type anything else to compile them on your server"
 read -e ZOLDUR
}

function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target
[Service]
User=$USERNAME
Group=$USERNAME
Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid
ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIGFOLDER/$CONFIG_FILE -datadir=$CONFIGFOLDER stop
Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5
[Install]
WantedBy=multi-user.target
EOF

}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1)
  RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
addnode=155.138.242.159:55350
addnode=209.250.253.96:55350
addnode=144.202.48.69:55350
addnode=134.209.198.90:55350
addnode=2.111.74.86:55350
addnode=178.128.34.150:55350
addnode=138.197.141.68:55350
addnode=157.230.124.196:55350
listen=1
server=1
daemon=1
rpcport=$RPC_PORT
EOF
}

function create_key() {
  echo -e "Enter your ${RED}$COIN_NAME Masternode Private Key${NC}. Leave it blank to generate a new ${RED}Masternode Private Key${NC} for you:"
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_PATH$COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_PATH$COIN_CLI masternode genkey)
  fi
  $COIN_PATH$COIN_CLI stop
fi
clear
}

function update_config() {
#   sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
logintimestamps=1
maxconnections=256
addressindex=1
txindex=1
#bind=$NODEIP
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
EOF
}

function save_key() {
	cd /$USERNAME/.EBITS
	mv /$USERNAME/.EBITS/ebits.conf /$USERNAME/.EBITS/ebits_old.conf
	cp /$USERNAME/.EBITS/ebits_old.conf /$USERNAME
}

function restore_key() {
	cd /$USERNAME/.EBITS
	rm masternode.conf
	cp /$USERNAME/ebits_old.conf /$USERNAME/.EBITS
	mv /$USERNAME/.EBITS/ebits_old.conf /$USERNAME/.EBITS/ebits.conf
}

function backup() {
	echo -e "We are going to zip all files to /$USERNAME as a backup before applying bootstrap."
	apt-get install -y zip unzip
	cd /$USERNAME/.EBITS
	rm -rf blocks_
	rm -rf blocks-
	rm blocks.sh
	zip -r backupdg.zip /$USERNAME/.EBITS
	cp /$USERNAME/.EBITS/backupdg.zip /$USERNAME
	
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  SSH_PORT=$(cat /etc/ssh/sshd_config | grep ^Port | tr -d 'Port ')
  ufw allow $SSH_PORT comment "SSH PORT $SSH_PORT"
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}



function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function checks() {
if [[ $(lsb_release -d) != *18.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 18.04. Installation is cancelled.${NC}"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}$0 must be run as root.${NC}"
   exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}

function prepare_system() {
 cd ~
   wget https://raw.githubusercontent.com/EmeraldMiningCo/Ebits/master/ebits.txt
#  wget https://gist.githubusercontent.com/hoserdude/9661c9cdc4b59cf5f001/raw/5972d4d838691c1a1f33fb274f97fa0b403d10bd/doge.txt
  cat ebits.txt
printf "%s\n"
echo "Ebits MN installer Depends Starting"
echo -e "Prepare the system to install ${GREEN}$COIN_NAME${NC} master node."
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${GREEN}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++ libzmq5 >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libzmq5"
 exit 1
fi

clear
}

function create_swap() {
 echo -e "Checking if swap space is needed."
 PHYMEM=$(free -g | awk '/^Mem:/{print $2}')
 SWAP=$(free -m | awk '/^Swap:/{print $2}')
 if [ "$PHYMEM" -lt "2" ] && [ "$SWAP" -lt "2000" ]
  then
    echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
    SWAPFILE=$(mktemp)
    dd if=/dev/zero of=$SWAPFILE bs=1024 count=2M
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon -a $SWAPFILE
 else
  echo -e "${GREEN}Server running with at least 2G of RAM, no swap needed.${NC}"
 fi
 clear
}

function start_service() {
  systemctl enable $COIN_NAME.service
  sleep 11
  systemctl start $COIN_NAME.service

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as sudo:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
 }

function important_information() {
 echo
 echo -e "================================================================================================================================"
 echo -e "$COIN_NAME Cold Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
 echo -e "MNCONF Line: mn1 ${RED}$NODEIP:$COIN_PORT${NC} ${RED}$COINKEY${NC} txhash txid "
 echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED}$COINKEY${NC}"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${RED}systemctl status $COIN_NAME.service${NC}"
 systemctl status $COIN_NAME.service
 echo -e "================================================================================================================================"
}

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  #blocks
  configure_systemd
  start_service
  important_information
}


##### Main #####
clear

ask_for_bootstrap
