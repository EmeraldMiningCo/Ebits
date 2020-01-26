NODEIP=$(curl -s4 icanhazip.com)

apt-get update
apt-get upgrade
apt-get install unzip
wget https://github.com/EmeraldMiningCo/Ebits/releases/download/0.17.0/EbitsLinux.zip
unzip ebits.zip

echo "installed"
./ebitsd -daemon
sleep 5
MNKEY=$(./ebits-cli masternode genkey)
sleep 1
./ebits-cli stop
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

./ebitsd -daemon -masternode
echo $MNKEY
