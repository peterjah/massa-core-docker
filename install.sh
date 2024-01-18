
#!/bin/bash

sudo apt-get update
sudo apt-get install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh ./get-docker.sh
rm get-docker.sh

curl -fsSL https://raw.githubusercontent.com/peterjah/massa-core-docker/main/docker-compose.yml -o docker-compose.yml

read  -p "Enter wallet privateKey: " privateKey

read  -p "Create a wallet password: " walletPassword
read  -p "Confirm your wallet password: " walletPasswordconf

if [ "$walletPassword" != "$walletPasswordconf" ]; then
    echo "Passwords do not match. Please try again."
    exit 1
fi

cat << EOF > .env
WALLETPWD=${walletPassword}
WALLET_PRIVATE_KEY=${privateKey}
EOF

sudo docker compose pull
sudo docker compose up -d

echo "Massa node is running in background. You can check logs with 'sudo docker compose logs -f' command."