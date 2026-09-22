# 🚀 AWS Resource Tracker using Shell Scripting

A hands-on **DevOps automation project** that uses **Bash Shell Scripting** and the **AWS CLI** to collect and display information about AWS resources from the command line.

The goal of this project is to understand how Shell Scripting can be used to automate common **AWS infrastructure monitoring and reporting tasks**.

---

## 📌 Project Overview

Managing multiple AWS resources manually can become time-consuming.

This project automates AWS resource discovery using a Bash script.

The script connects to AWS through the **AWS CLI** and retrieves information about resources such as:

* 🖥️ EC2 Instances
* 🪣 S3 Buckets
* ⚡ Lambda Functions
* 👤 IAM Users
* 🌐 VPC Resources
* 🗄️ RDS Instances

The collected information is displayed in a simple terminal-based report.

---

## 🏗️ Project Architecture

```text
                ┌─────────────────────┐
                │   Bash Shell Script │
                │ aws_resource_tracker│
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │      AWS CLI        │
                └──────────┬──────────┘
                           │
             ┌─────────────┼─────────────┐─────────────┐
             ▼             ▼             ▼             ▼
           EC2            S3           Lambda       IAM Users
             │             │             │             │ 
             └─────────────┼─────────────┘─────────────┘
                           ▼
                    AWS Resources
                           │
                           ▼
                  Terminal Report
```


> ⚠️ Never push `.pem` files, AWS access keys, secret keys, or other credentials to GitHub.

---

# 🚀 Project Setup

## Step 1 — Launch an EC2 Instance

Launch an Ubuntu EC2 instance in AWS.

Connect to the instance using SSH:

```bash
ssh -i report-key.pem ubuntu@<EC2-PUBLIC-IP>
```

Example:

```bash
ssh -i report-key.pem ubuntu@54.166.188.175
```

---

## Step 2 — Install AWS CLI

Update the package information:

```bash
sudo apt install unzip -y
```

Verify the installation:

```bash
aws --version
```
<img width="1046" height="562" alt="image" src="https://github.com/user-attachments/assets/a4ffd010-58dc-467d-a58d-7c4ecaafbfae" />

---

# 🔐 Step 3 — Configure AWS Authentication

For this project, I used an **AWS IAM User** to authenticate the AWS CLI.

The IAM User was configured with the required permissions to access the AWS resources used by the Resource Tracker.

Configure AWS CLI using:

```bash
aws configure
```

The CLI will ask for:

```text
AWS Access Key ID:
AWS Secret Access Key:
Default region name:
Default output format:
```

After configuration, verify the AWS identity:

```bash
aws sts get-caller-identity
```

If authentication is successful, AWS returns information about the IAM identity being used.

Example:

```json
{
    "UserId": "AIDAXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/aws-resource-tracker"
}
```

> ⚠️ **Security:** Never commit AWS Access Keys, Secret Access Keys, or other credentials to GitHub. Use `.gitignore` for local credential files and revoke credentials if they are accidentally exposed.


---

# 📝 Step 4 — Create the AWS Resource Tracker Shell Script

The main automation logic of this project is implemented in:

```text
aws_resource_tracker.sh
```

I created the Bash script using:

```bash
nano aws_resource_tracker.sh
```

After creating the script, I made it executable:

```bash
chmod +x aws_resource_tracker.sh
```

The script can then be executed using:

```bash
./aws_resource_tracker.sh
```
<img width="565" height="52" alt="image" src="https://github.com/user-attachments/assets/922b7dc3-6297-4afe-8613-f6af7946f2a1" />

Now check the report :

```bash
cat aws_resource_report_$(date +%Y-%m-%d).txt
```

<img width="977" height="645" alt="image" src="https://github.com/user-attachments/assets/a4b49b62-055c-495d-8091-0ddf5b17d16f" />


### 🔹 What does the script do?

The script uses **Bash Shell Scripting** together with the **AWS CLI** to collect information about AWS resources and generate a **daily resource report**.

The current version tracks four AWS resources:

* 🖥️ **EC2 Instances**
* 🪣 **S3 Buckets**
* ⚡ **Lambda Functions**
* 👤 **IAM Users**

The generated report contains the resource information along with the **report date** and **AWS region**.

---

## 🔹 1. Creating the Report File

The script first creates a report filename using the current date:

```bash
REPORT_FILE="aws_resource_report_$(date +%Y-%m-%d).txt"
```

Here:

* `REPORT_FILE` → Bash variable
* `$(date +%Y-%m-%d)` → command substitution
* `date` → gets the current date
* `%Y-%m-%d` → formats the date as `YYYY-MM-DD`

For example:

```text
aws_resource_report_2026-09-21.txt
```

This allows the script to create a separate report for each day.

---

## 🔹 2. Creating the Report Header

The script uses `echo` to write information into the report:

```bash
echo "========================================" > "$REPORT_FILE"
echo "       AWS DAILY RESOURCE REPORT" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "Report Date (IST): $(TZ=Asia/Kolkata date)" >> "$REPORT_FILE"
echo "AWS Region: $(aws configure get region)" >> "$REPORT_FILE"
```

Here, the important concept is **output redirection**.

### `>`

```bash
>
```

Creates the file or overwrites its existing contents.

### `>>`

```bash
>>
```

Appends new content to the existing file.

The script therefore progressively builds the report instead of only displaying the information in the terminal.

---

## 🖥️ 3. Tracking EC2 Instances

The script uses the AWS CLI to retrieve EC2 information:

```bash
aws ec2 describe-instances
```

To extract only the required information, it uses the AWS CLI `--query` option:

```bash
aws ec2 describe-instances \
    --query "Reservations[].Instances[].[InstanceId,State.Name,InstanceType]" \
    --output table
```

This extracts:

* **Instance ID**
* **Instance State**
* **Instance Type**

The result is formatted as a table using:

```bash
--output table
```

The script also calculates the total number of EC2 instances:

```bash
aws ec2 describe-instances \
    --query "Reservations[].Instances[].InstanceId" \
    --output text | wc -w
```

Here, the Linux pipe:

```bash
|
```

passes the output of the AWS CLI command to:

```bash
wc -w
```

which counts the returned words.

This demonstrates how **AWS CLI commands can be combined with Linux commands inside a Bash script**.

---

## 🪣 4. Tracking S3 Buckets

For S3, the script uses:

```bash
aws s3api list-buckets
```

To calculate the total number of buckets:

```bash
aws s3api list-buckets \
    --query "length(Buckets)" \
    --output text
```

To retrieve the bucket names:

```bash
aws s3api list-buckets \
    --query "Buckets[].Name" \
    --output table
```

This demonstrates how AWS CLI's **JMESPath `--query` functionality** can be used to extract specific information from AWS API responses.

---

## ⚡ 5. Tracking Lambda Functions

The script retrieves Lambda functions using:

```bash
aws lambda list-functions
```

The total number of Lambda functions is obtained using:

```bash
aws lambda list-functions \
    --query "length(Functions)" \
    --output text
```

The function names are retrieved using:

```bash
aws lambda list-functions \
    --query "Functions[].FunctionName" \
    --output table
```

The report therefore contains both the **total number of Lambda functions** and their names.

---

## 👤 6. Tracking IAM Users

For IAM, the script uses:

```bash
aws iam list-users
```

The total number of IAM users is calculated using:

```bash
aws iam list-users \
    --query "length(Users)" \
    --output text
```

The usernames are retrieved using:

```bash
aws iam list-users \
    --query "Users[].UserName" \
    --output table
```

This allows the daily report to contain a basic **IAM user inventory**.

---

## 📄 7. Generating the Final Report

After collecting information about all four AWS resources, the script adds a completion message:

```bash
echo "========================================" >> "$REPORT_FILE"
echo "Report generated successfully!" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
```

Finally, it displays the generated report filename in the terminal:

```bash
echo "AWS Resource Report generated:"
echo "$REPORT_FILE"
```

<img width="565" height="52" alt="image" src="https://github.com/user-attachments/assets/d72af2dc-1b7e-4189-a1e7-5105dfc0ce3f" />



The overall workflow is:

```text
                AWS EC2
                   │
                   ▼
        aws_resource_tracker.sh
                   │
             Bash Script
                   │
                   ▼
              AWS CLI
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼          ▼
      EC2         S3       Lambda       IAM
        │          │          │           │
        └──────────┴──────────┴───────────┘
                   │
                   ▼
          AWS Resource Report
                   │
                   ▼
aws_resource_report_YYYY-MM-DD.txt
```

The next stage is to automate the execution using a **Linux Cron Job**, so the script runs automatically **every day at 6:00 PM** and generates the daily AWS resource report without requiring manual execution.


# Step 5 — Automate the Report Using Cron Job

After creating and testing the Bash script, the next step is to automate its execution. Instead of manually running the script every day, we use a **Linux Cron Job** to automatically execute the AWS Resource Tracker at **6:00 PM IST every day**.

## 5.1 Check Server Timezone

First, check the EC2 server's current date and time

```bash
date
```

Example:

```text
Mon Sep 21 15:43:10 UTC 2026
```

The EC2 server is using **UTC** timezone.

Since India Standard Time (IST) is **UTC + 5:30**:

```text
6:00 PM IST
     ↓
12:30 PM UTC
```

Therefore, the Cron Job needs to run at **12:30 UTC**.

---

## 5.2 Find the Script Path

Check the current directory:

```bash
pwd
```

Example:

```text
/home/ubuntu
```

Verify that the script exists:

```bash
ls -l aws_resource_tracker.sh
```

The complete script path is:

```text
/home/ubuntu/aws_resource_tracker.sh
```

---

## 5.3 Open the Crontab

Open the user's Cron configuration:

```bash
crontab -e
```

Add the following line:

```cron
30 12 * * * /home/ubuntu/aws_resource_tracker.sh
```

Save and exit the editor.
<img width="682" height="287" alt="image" src="https://github.com/user-attachments/assets/19f8cdbb-d2fe-4f16-9dc1-dcfa7249659e" />


---

## 5.4 Understand the Cron Expression

The Cron format is:

```text
minute hour day-of-month month day-of-week command
```

Our Cron Job:

```cron
30 12 * * * /home/ubuntu/aws_resource_tracker.sh
```

means:

| Field   |       Value | Meaning                      |
| ------- | ----------: | ---------------------------- |
| Minute  |        `30` | At minute 30                 |
| Hour    |        `12` | At 12 PM UTC                 |
| Day     |         `*` | Every day                    |
| Month   |         `*` | Every month                  |
| Weekday |         `*` | Every day of the week        |
| Command | Script path | Run the AWS Resource Tracker |

Therefore:

```text
12:30 PM UTC
      ↓
6:00 PM IST
      ↓
AWS Resource Tracker Script
      ↓
AWS Resource Report
```

---

## 5.5 Verify the Cron Job

After saving the Cron configuration, verify it using:

```bash
crontab -l
```

Expected output:

```cron
30 12 * * * /home/ubuntu/aws_resource_tracker.sh
```

This confirms that the Cron Job has been successfully configured.
<img width="836" height="511" alt="image" src="https://github.com/user-attachments/assets/166d2b9a-ead6-40fe-b2e9-04985b6b2082" />

---

## 5.6 Test the Script Before Waiting for 6 PM

The script can be executed manually to make sure it works correctly:

```bash
./aws_resource_tracker.sh
```

Then check the generated report:

```bash
ls -lh aws_resource_report_*.txt
```
<img width="877" height="106" alt="image" src="https://github.com/user-attachments/assets/025c44ae-35fb-49ce-b8ac-8fc7f034ed56" />

View the report:

```bash
cat aws_resource_report_$(date +%Y-%m-%d).txt
```
<img width="1912" height="1021" alt="image" src="https://github.com/user-attachments/assets/002e6789-19e3-4b75-8c83-c3754ea6ebb2" />

---

## 5.7 Test Cron Without Waiting

For testing purposes, the Cron schedule can temporarily be changed to run every minute:

```cron
* * * * * /home/ubuntu/aws_resource_tracker.sh
```

After waiting approximately one or two minutes, check whether a report was generated.

Once testing is complete, restore the actual schedule:

```cron
30 12 * * * /home/ubuntu/aws_resource_tracker.sh
```

---

## 5.8 Automation Flow

```text
                    Linux Cron
                       │
                       │ Every day at 6 PM IST
                       ▼
             aws_resource_tracker.sh
                       │
                       ▼
                  AWS CLI
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
       EC2            S3           Lambda
        │              │              │
        └──────────────┼──────────────┘
                       ▼
                      IAM
                       │
                       ▼
              AWS Resource Report
                       │
                       ▼
        aws_resource_report_YYYY-MM-DD.txt
```

### Final Automation

The completed automation now works like this:

```text
AWS EC2 Linux Server
        ↓
     Cron Job
        ↓
Every day at 6:00 PM IST
        ↓
aws_resource_tracker.sh
        ↓
AWS CLI
        ↓
EC2 | S3 | Lambda | IAM
        ↓
Daily AWS Resource Report
```

The script no longer needs to be executed manually every day. **Cron automatically triggers the Bash script according to the defined schedule.**

---

## 🛠️ Technologies Used

| Technology                 | Purpose                       |
| -------------------------- | ----------------------------- |
| **Bash / Shell Scripting** | Automation                    |
| **AWS CLI**                | Interacting with AWS services |
| **Amazon EC2**             | Compute resource tracking     |
| **Amazon S3**              | Bucket tracking               |
| **AWS Lambda**             | Function tracking             |
| **AWS IAM**                | User tracking                 |
| **Linux**                  | Script execution environment  |
| **Git & GitHub**           | Version control               |

---

---

# 🎯 What I Learned

Through this project, I practiced:

* Bash scripting fundamentals
* Linux command-line operations
* AWS CLI
* AWS IAM
* EC2
* S3
* Lambda
* AWS authentication
* Shell variables and commands
* Command execution
* Bash debugging using `set -x`
* AWS CLI `--query`
* AWS CLI output formatting
* Automating repetitive cloud operations
* Git and GitHub workflow

---

# 🔮 Future Improvements

The project can be extended with:

* [ ] Add VPC resource tracking
* [ ] Add RDS resource tracking
* [ ] Add EBS volume tracking
* [ ] Add Security Group tracking
* [ ] Add AWS Cost information
* [ ] Generate CSV reports
* [ ] Generate HTML reports
* [ ] Add error handling
* [ ] Add logging
* [ ] Schedule the script using Cron
* [ ] Upload reports to Amazon S3
* [ ] Add GitHub Actions CI
* [ ] Send automated email/Slack notifications

---

# 📌 Future Automation Flow

The long-term goal is to turn this into an automated cloud reporting workflow:

```text
AWS Resources
      ↓
AWS CLI
      ↓
Bash Script
      ↓
Resource Report
      ↓
CSV / HTML
      ↓
Amazon S3
      ↓
Scheduled Automation
```

---

## 👩‍💻 Author

**Nitika Rawat**

AWS DevOps / Cloud Engineer

Skills practiced in this project:

**AWS | Linux | Bash | AWS CLI | EC2 | S3 | IAM | Lambda | Git | GitHub**
