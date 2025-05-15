#!/bin/bash

# Update & install dependencies
yum update -y
amazon-linux-extras enable java-openjdk17
yum install -y java-17-amazon-corretto-devel wget unzip amazon-efs-utils jq aws-cli

# Create Sonar user and directories
groupadd -g 5000 sonar
useradd -u 1001 -g 5000 -m sonar


# Download and install SonarQube
cd /opt
wget "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
unzip "sonarqube-${SONARQUBE_VERSION}.zip"
mv "sonarqube-${SONARQUBE_VERSION}" sonarqube
chown -R sonar:sonar /opt/sonarqube

# Mount data
echo "${EFS_FS_ID}:/ /opt/sonarqube/data efs _netdev,tls,accesspoint=${DATA_AP_ID},iam, 0 0" >> /etc/fstab
echo "${EFS_FS_ID}:/ /opt/sonarqube/extensions efs _netdev,tls,accesspoint=${EXT_AP_ID},iam, 0 0" >> /etc/fstab
mount -a

# Fetch DB credentials from Secrets Manager
SECRET_ARN="${RDS_SECRET_ARN}"
DB_HOST="${RDS_ENDPOINT}"
DB_NAME="${RDS_DB_NAME}"
REGION="${REGION}"

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --region $REGION --query SecretString --output text)
DB_USER=$(echo $CREDENTIALS | jq -r .username)
DB_PASS=$(echo $CREDENTIALS | jq -r .password)

# Configure SonarQube DB connection
SONAR_CONFIG="/opt/sonarqube/conf/sonar.properties"
sed -i "s|^#sonar.jdbc.username=.*|sonar.jdbc.username=$DB_USER|" $SONAR_CONFIG
sed -i "s|^#sonar.jdbc.password=.*|sonar.jdbc.password=$DB_PASS|" $SONAR_CONFIG
echo "sonar.jdbc.url=jdbc:postgresql://$DB_HOST/$DB_NAME" >> $SONAR_CONFIG

# Create systemd service
cat <<EOT > /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT


sysctl -w vm.max_map_count=262144

# Start SonarQube
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube