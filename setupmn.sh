NODEIP=$(curl -s4 icanhazip.com)

apt-get update
apt-get upgrade
apt-get install unzip
wget https://github.com/EmeraldMiningCo/Ebits/releases/download/0.17.2/Ebits0172Linux.zip
unzip Ebits0172Linux.zip

echo "installed"

./Ebits0172Linux/ebitsd -daemon
sleep 5
MNKEY=$(./Ebits0172Linux/ebits-cli masternode genkey)
sleep 1
./Ebits0172Linux/ebits-cli stop
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

EOF

./Ebits0172Linux/ebitsd -daemon -masternode
echo $NODEIP
echo $MNKEY
