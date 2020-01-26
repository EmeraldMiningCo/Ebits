NODEIP=$(curl -s4 icanhazip.com)

apt-get update
apt-get upgrade
apt-get install unzip
wget https://github.com/EmeraldMiningCo/Ebits/releases/download/0.17.0/EbitsLinux.zip
unzip EbitsLinux.zip

echo "installed"

./EbitsLinux/ebitsd -daemon
sleep 5
MNKEY=$(./EbitsLinux/ebits-cli masternode genkey)
sleep 1
./EbitsLinux/ebits-cli stop
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

./EbitsLinux/ebitsd -daemon -masternode
echo $NODEIP
echo $MNKEY
