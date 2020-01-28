NODEIP=$(curl -s4 icanhazip.com)

apt-get update
apt-get upgrade
apt-get install unzip
wget https://github.com/EmeraldMiningCo/Ebits/releases/download/0.17.1/Ebits0171Linux.zip
unzip Ebits0171Linux.zip

echo "installed"

./Linux/ebitsd -daemon
sleep 5
MNKEY=$(./Linux/ebits-cli masternode genkey)
sleep 1
./Linux/ebits-cli stop
sleep 5
echo "generated mnkey"

cat << EOF >> .EBITS/ebits.conf

rpcuser=user
rpcpassword=password
server=1
listen=1
externalip=$NODEIP
rpcallowip=127.0.0.1
rpcport=99901
staking=0
masternode=1
masternodeprivkey=$MNKEY
addnode=155.138.242.159:15350
addnode=209.250.253.96:15350
addnode=144.202.48.69:15350
addnode=134.209.198.90:15350
addnode=2.111.74.86:15350
addnode=178.128.34.150:15350
addnode=138.197.141.68:15350
addnode=157.230.124.196:15350

EOF

./Linux/ebitsd -daemon -masternode
echo $NODEIP
echo $MNKEY
