#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SGI_ID="sg-01ade26956bf74218"
INSTANCES=("mongodb" "redis")  
ZONE_ID="Z10073371KESZAOI9YC5L"
DOMAIN_NAME="daws84s.space"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01bc7ebe005fb1cb2 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
       
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "$instance  IP address: $IP"
done 
