#!/bin/bash
# shellcheck disable=SC2059

set -e

NEW_SIZE_SLUG=""

while test $# -gt 0
do
        case "$1" in
                --tiny) NEW_SIZE_SLUG=s-1vcpu-512mb
                ;;
                --small) NEW_SIZE_SLUG=s-1vcpu-1gb
                ;;
                --large) NEW_SIZE_SLUG=s-2vcpu-2gb
                ;;
        esac
        shift
done

if [[ ${NEW_SIZE_SLUG} = "" ]];then
  echo "You must supply a size as an argument:"
  echo "--tyny \$4 - 512MB 1 vCPU"
  echo "--small \$6 - 1GB 1 vCPU"
  echo "--large \$18 - 2GB 2 vCPU"
  exit
fi

YELLOW='\033[1;33m'
#BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

# Getting a token
#https://docs.digitalocean.com/reference/api/create-personal-access-token/

# Installing DO CLI
#https://docs.digitalocean.com/reference/doctl/how-to/install/

# CLI Reference
#https://docs.digitalocean.com/reference/doctl/reference/compute/droplet/

# One time, as instructed above
#doctl auth init --context ekpyroticfrood

printf "\n${YELLOW}Digital Ocean Account and Droplet Info${NC}\n"
doctl auth list
doctl auth switch --context ekpyroticfrood
doctl compute droplet list

DROPLET_ID=338690043

# Get size slugs
#doctl compute size list

printf "\n${YELLOW}Powering Down EkpyroticFrood${NC}\n"
doctl compute droplet-action power-off ${DROPLET_ID} --wait

printf "\n${YELLOW}Resizing EkpyroticFrood${NC}\n"
doctl compute droplet-action resize 338690043 --size ${NEW_SIZE_SLUG} --wait

printf "\n${YELLOW}Powering Up EkpyroticFrood${NC}\n"
doctl compute droplet-action power-on ${DROPLET_ID} --wait
