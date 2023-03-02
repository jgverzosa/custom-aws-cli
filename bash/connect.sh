#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

printf "AWS EC2 server\n"
PS3='Select a server:'
options=("ASG" "Cloud" "Webserv")
select opt in "${options[@]}"
do
    case $opt in
        "ASG")
            serverName="Asg"
            server="oov7-stack/OOV7ASG" 
            break;
            ;;
        "Cloud")
            serverName="Cloud"
            server="delit-avmh-web-01" 
            break;
            ;;
        "Webserv")
            serverName="Webserv"
            server="dsoft-avmh-webserv-01" 
            break;
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

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
        "Production")
            env="default"
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

aws_instance="aws ssm --profile ${env} describe-instance-information --output text --query \"InstanceInformationList[*].[InstanceId]\" --filters \"Key=tag:Name,Values=${server}\""
instances=$(eval $aws_instance)

instance_array=(${instances//$'\n'/ })
if [ $instance_array ]
then
  printf "Instance ID/s (${#instance_array[@]}):\n"
  printf "$instances\n\n"
  current_instance=${instance_array[0]}
  read -p "Enter Instance Id [?] Help (default is ${current_instance}): " input_instance

  if [ ! -z $input_instance ]
  then
    current_instance=$input_instance
  fi
  
  printf "\U2705 ${GREEN}Connecting to $current_instance ${NC}\n"

  aws --profile $env ssm start-session --target $current_instance


else
  printf "\U1F6D1 No Instance\n\n"
  exit;
fi




# aws --profile ditdev ssm start-session --target $instances
