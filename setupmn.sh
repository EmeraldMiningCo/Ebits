NODEIP=$(curl -s4 icanhazip.com)

apt-get update
apt-get upgrade
apt-get install unzip
wget wget https://bashupload.com/INMrS/ebits.zip
unzip ebits.zip

cd EbitsNewMN
./root/ebitsd -daemon
MNKEY=$(./ebits-cli masternode genkey)
./root/ebits-cli stop

cat << EOF >> /root/.EBITS/ebits.conf

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

echo -e "$MNKEY"
cd
./root/ebitsd -daemon -masternode
