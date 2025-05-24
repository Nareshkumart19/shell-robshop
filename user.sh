#!/bin/bash
start_time=$(date +%s) 
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


curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
VALIDATE $? "Dowlinding catalouge "

rm -rf /app/*
cd /app 

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unziping catlouge"

npm install &>>$LOG_FILE
VALIDATE $?  "installing dependies"


cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "copy the calalogue service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable user  &>>$LOG_FILE
systemctl start user
VALIDATE $? "starting user"


end_time=$(date +%s)

total_time=$((end_time - start_time))
echo  -e "Total execution time:   Y $total_time seconds" $N | tee -a &>>$LOG_FILE



#$mongosh --host mongodb.daws84s.space </app/db/master-data.js &>>$LOG_FILE
#VALIDATE $? "loding data into mongdb"

#STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("user")')
#if [ $STATUS -lt 0 ]
#then
#    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
#    VALIDATE $? "Loading data into MongoDB"
#else
#    echo -e "Data is already loaded ... $Y SKIPPING $N"
#fi