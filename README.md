# Observability & Security AWS Platform

This project demonstrates the design and implementation of a **security-focused, observable AWS infrastructure platform** built using **Terraform** and AWS native services.

The platform goes beyond basic high availability by implementing **centralized logging, audit trails, runtime secrets management, least-privilege IAM, and blast-radius controls**, aligning with real-world enterprise cloud security practices.

## 🎯 Project Objectives

- Build a highly available AWS infrastructure using EC2, ALB, and Auto Scaling
- Implement centralised observability across infrastructure and security events
- Enforce least privilege and runtime secrets access
- Protect logs and audit data against tampering
- Demonstrate production ready AWS security patterns

## 🏗️ Architecture Overview

### Infrastructure Layer

- EC2 instances in an Auto Scaling Group
- Application Load Balancer (ALB)
- VPC with public and private subnets
- Security Groups enforcing least privilege networking

### Observability

- Amazon CloudWatch metrics and alarms
- Centralised application and access logs
- ALB access logs stored in Amazon S3
- CloudWatch Logs for EC2 and application telemetry

### Security & Audit

- AWS CloudTrail enabled for management and data events
- Dedicated, immutable S3 bucket for audit logs
- S3 bucket policies enforcing log integrity
- Runtime secrets stored in AWS Secrets Manager
- IAM permissions boundaries to limit blast radius

## 🔐 Security Design Principles

This project is intentionally designed around **security-first principles**:

- No hardcoded secrets in Terraform, code, or user data
- Secrets retrieved **at runtime** using IAM roles
- CloudTrail logs protected from deletion or modification
- IAM permissions boundaries prevent privilege escalation
- Full auditability via CloudTrail and CloudWatch

## 📦 Services Used

- **Compute:** EC2, Auto Scaling Group
- **Networking:** VPC, Subnets, Security Groups, ALB
- **Observability:** CloudWatch Metrics, Logs, Alarms
- **Audit & Compliance:** CloudTrail, S3
- **Secrets Management:** AWS Secrets Manager
- **IAM & Security:** IAM Roles, Policies, Permissions Boundaries
- **Infrastructure as Code:** Terraform

## 📁 Repository Structure

```bash
├── alb.tf
├── asg.tf
├── cloudtrail.tf
├── cloudwatch.tf
├── iam.tf
├── launch_template.tf
├── main.tf
├── s3.tf
├── security_groups.tf
├── secrets.tf
├── sns.tf
├── alb.tf
├── user_data.sh
├── variables.tf
└── vpc.tf
 ```

## 🔑 Secrets Management

This project intentionally separates **infrastructure provisioning** from **secret values**.

### How secrets are handled

- Terraform creates the AWS Secrets Manager resource
- Secret values are **not stored** in Terraform or Git
- Secrets are injected manually via:
  - AWS Console (**recommended**)
  - Secure CLI workflows
  - CI/CD pipelines

### Runtime secret retrieval example

```bash
aws secretsmanager get-secret-value \
  --secret-id observability/app/config \
  --query SecretString \
  --output text
```

## 🔐 Security & Secrets Management

This ensures:

- No secrets in source control  
- No secrets in Terraform state  
- Full audit trail via CloudTrail  

## 🧱 Log Integrity & Blast Radius Control

- CloudTrail logs are delivered to a **dedicated S3 bucket**
- Bucket policies enforce:
  - Write only access for CloudTrail
  - Explicit denial of delete actions
- IAM permissions boundaries prevent:
  - IAM modification
  - CloudTrail disablement
  - Destructive S3 actions

This design protects against both accidental misconfiguration and malicious actions.

## 🚀 Deployment Instructions

### Prerequisites

- AWS CLI configured
- An AWS account with sufficient permissions  

### Deployment Steps

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### After Deployment

- Inject secret values into **AWS Secrets Manager**
- Verify **CloudWatch alarms** are active
- Confirm **CloudTrail logs** are delivered to S3

## 🧠 Key Learning Outcomes

- Designing observable AWS infrastructure  
- Implementing security controls beyond basic HA  
- Managing secrets safely in production environments  
- Applying IAM permissions boundaries  
- Protecting audit logs and minimising blast radius  

## 📌 Why This Project Matters

This project reflects real enterprise AWS patterns.

- Security-first design  
- Auditability and compliance awareness  
- Operational visibility  
- Infrastructure as Code best practices  

## 🔗 Related Projects

- AWS Serverless Web Platform (Lambda, API Gateway, DynamoDB)  
- High Availability AWS Infrastructure (EC2, ALB, ASG)  
- CI/CD with Terraform & GitHub Actions
