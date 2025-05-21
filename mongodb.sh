#!/bin/bash

userid=$(id -u)


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGFOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0  | cut -d "." -f1)
LOGFILE="$LOGFOLDER/$SCRIPT_NAME.log"


mkdir -p $LOGFOLDER
echo "script started exeuted at : $(date)" | tee -a $LOG_FILE

if [ $userid -ne 0 ]
then
    echo -e "ERROR $R run the script with root use $N" | tee -a $LOGFILE
    exit 1
else
    echo "you are in root user"
fi 


VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e " $2    ....$G sucessfully $N" | tee -a $LOGFILE
    else
        echo -e " $2 . $R   failure $N" | tee -a $LOGFILE
        exit 1s
    fi
}


cp mongo.repo /etc/yum.repos.d/naresh.repo
VALIDATE $! "copy mongo repo"

dnf install mongodb-org -y  &>>$LOGFILE
VALIDATE $? "installing mongodb server"

systemctl enable mongod  &>>$LOGFILE
VALIDATE $? "enabling mongodb server"

systemctl start mongod  &>>$LOGFILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf  
VALIDATE $? "editing mongodb conf  file for remote connection"

systemctl restart mongod &>>$LOGFILE
VALIDATE $? "restarting mongodb service "