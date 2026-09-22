#!/bin/bash

#AWS Resource Tracker
# This script generates a daily AWS resource reports
# version : v1
#
############################################

#We will be tracking :
# AWS S3
# AWS EC2
# AWS IAM USERS 
# AWS Lambda 


REPORT_FILE="aws_resource_report_$(date +%Y-%m-%d).txt"

echo "========================================" > "$REPORT_FILE"
echo "       AWS DAILY RESOURCE REPORT" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "Report Date (IST): $(TZ=Asia/Kolkata date)" >> "$REPORT_FILE"
echo "AWS Region: $(aws configure get region)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"


# -----------------------------
# EC2 INSTANCES
# -----------------------------

echo "----------------------------------------" >> "$REPORT_FILE"
echo "EC2 INSTANCES" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

echo "Total EC2 Instances:" >> "$REPORT_FILE"

aws ec2 describe-instances \
    --query "Reservations[].Instances[].InstanceId" \
    --output text | wc -w >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

aws ec2 describe-instances \
    --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType]" \
    --output table >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"


# -----------------------------
# S3 BUCKETS
# -----------------------------

echo "----------------------------------------" >> "$REPORT_FILE"
echo "S3 BUCKETS" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

echo "Total S3 Buckets:" >> "$REPORT_FILE"

aws s3api list-buckets \
    --query "length(Buckets)" \
    --output text >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

aws s3api list-buckets \
    --query "Buckets[].Name" \
    --output table >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"


# -----------------------------
# LAMBDA FUNCTIONS
# -----------------------------

echo "----------------------------------------" >> "$REPORT_FILE"
echo "LAMBDA FUNCTIONS" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

echo "Total Lambda Functions:" >> "$REPORT_FILE"

aws lambda list-functions \
    --query "length(Functions)" \
    --output text >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

aws lambda list-functions \
    --query "Functions[].FunctionName" \
    --output table >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"


# -----------------------------
# IAM USERS
# -----------------------------

echo "----------------------------------------" >> "$REPORT_FILE"
echo "IAM USERS" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

echo "Total IAM Users:" >> "$REPORT_FILE"

aws iam list-users \
    --query "length(Users)" \
    --output text >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

aws iam list-users \
    --query "Users[].UserName" \
    --output table >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"


# -----------------------------
# REPORT COMPLETED
# -----------------------------

echo "========================================" >> "$REPORT_FILE"
echo "Report generated successfully!" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"

echo "AWS Resource Report generated:"
echo "$REPORT_FILE"

