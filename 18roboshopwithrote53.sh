#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SGI_ID="sg-01ade26956bf74218"
INSTANCES=("mongodb" "frontend")  
ZONE_ID="Z10073371KESZAOI9YC5L"
DOMAIN_NAME="daws84s.space"

#run the script  with user  
for instance in ${INSTANCES[@]}
#for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01ade26956bf74218 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
          RECORD_NAME="$instance.$DOMAIN_NAME"
    else
         IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
          RECORD_NAME="$DOMAIN_NAME"  
    fi
    echo "$instance  IP address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
      {  "Comment": "Creating and update a record set for cognito endpoint"
      ,"Changes": [{
          "Action"              : "UPSERT"
          ,"ResourceRecordSet"  : {
            "Name"              : "'$instance'.'$DOMAIN_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
          }
        }]
      }'
done 

   