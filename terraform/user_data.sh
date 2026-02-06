#!/bin/bash

# Update and install packages
yum update -y && yum install -y httpd amazon-cloudwatch-agent awscli

# Start services
systemctl enable --now httpd
systemctl enable --now amazon-ssm-agent

# Wait a few seconds to ensure httpd is ready before ALB health check
sleep 15

# Write web page
echo "<h1>Observability and Security Platform on AWS</h1>" > /var/www/html/index.html

# CloudWatch Agent configuration
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/ec2/httpd/access",
                        "log_stream_name": "{instance_id}"
                    },
                    {   
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/ec2/httpd/error",
                        "log_stream_name": "{instance_id}"
                    }
                ]            
            }
        }
    }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Retrieve secret
SECRET=$(aws secretsmanager get-secret-value \
    --secret-id app/secret \
    --query SecretString \
    --output text)

echo "$SECRET" > /etc/app_secrets.json
chmod 600 /etc/app_secrets.json
