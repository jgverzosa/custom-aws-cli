#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color


printf "\U2728 ${GREEN}Server: $serverName (Name: $server)${NC} \n\n" 

printf "Select AWS environment:\n"
PS3='Select environment:'
options=("Staging" "Production" "Development")
select opt in "${options[@]}"
do
    case $opt in
        "Staging")
            env="ditstg"
            break;
            ;;
        "Development")
            env="ditdev"
            break;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
printf "\U2728 ${GREEN}Environment: $env ${NC}\n\n"

read -p "Enter Instance Id: " input_instance
read -p "Enter Port: " input_port

printf "\U2705 ${GREEN}Tunneling ${input_instance}:${input_port} ${NC}\n"

aws ssm start-session --profile $env --target "${input_instance}" --document-name AWS-StartPortForwardingSession --parameters "localPortNumber=${input_port},portNumber=${input_port}"
