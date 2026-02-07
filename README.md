utomated Monitoring & Remediation Workflow
This project demonstrates a production-inspired monitoring and automation solution based on real-world cloud engineering practices.

The solution detects API performance degradation using log-based monitoring, triggers automated remediation via AWS Lambda, and provisions infrastructure using Terraform for repeatability and compliance.

Architecture Overview
Log-based alert detects sustained API latency
Alert triggers AWS Lambda remediation
Lambda safely reboots EC2 instance
Notification sent via SNS
Infrastructure provisioned using Terraform

Assumptions
Sumo Logic alert integration is simulated
EC2 restart is an acceptable first-level remediation
Single-instance architecture for demonstration purposes

Tools & Technologies
AWS EC2, Lambda, SNS, IAM
Terraform
Python (boto3)
Sumo Logic