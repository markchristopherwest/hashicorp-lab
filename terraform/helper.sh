#!/bin/bash

set -e

sleep 5



apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg
apt-get install -y wget gpg libcap2-bin 

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | tee /etc/apt/sources.list.d/hashicorp.list

apt-get update
apt-get install -y terraform vault

setcap cap_ipc_lock= /usr/bin/vault

which vault

# export VAULT_ROOT_TOKEN="root"
# export VAULT_TOKEN=$VAULT_ROOT_TOKEN
export VAULT_ADDR="http://host.docker.internal:8200"
export VAULT_SKIP_VERIFY=true
# vault login root

echo "Initializing Vault"
vault operator init > /secrets/vault.txt
# cat /secrets/vault.txt > /secrets/vault.txt

echo "Sourcing Vault"
export VAULT_TOKEN=$(cat /secrets/vault.txt | grep '^Initial' | awk '{print $4}')
export UNSEAL_1=$(cat /secrets/vault.txt | grep '^Unseal Key 1' | awk '{print $4}')
export UNSEAL_2=$(cat /secrets/vault.txt | grep '^Unseal Key 2' | awk '{print $4}')
export UNSEAL_3=$(cat /secrets/vault.txt | grep '^Unseal Key 3' | awk '{print $4}')

echo "Unsealing Vault"
vault operator unseal $UNSEAL_1
vault operator unseal $UNSEAL_2
vault operator unseal $UNSEAL_3

# Handle Vault Login
export ROOT_TOKEN=${VAULT_TOKEN}
vault login ${ROOT_TOKEN} >> helper.log

# TF it
cd /
cd /terraform
terraform init >> helper.log
terraform apply -auto-approve >> helper.log

# Back to KMIP
# cd /secrets