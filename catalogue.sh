#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling default nodejs"


dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enablinh nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "insatalling nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    
    VALIDATE $? "creating roboshop system user"
else 
    echo -e "system user roboshop alraedy cretaed .... $Y skipping $N"
fi    
mkdir -p /app 
VALIDATE $? "careating app  directory"


curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Dowlinding catalouge "

rm -rf /app/*
cd /app 

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unziping catlouge"

npm install &>>$LOG_FILE
VALIDATE $?  "installing dependies"


cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "copy the calalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable catalogue  &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "starting catalogue"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing Mongodb client"

mongosh --host mongodb.daws84s.space </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "loding data into mongdb"
