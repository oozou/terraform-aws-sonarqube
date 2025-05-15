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





#!/bin/bash
set -e

# Update & install dependencies
sudo yum update -y
sudo amazon-linux-extras enable java-openjdk17
sudo yum install -y java-17-amazon-corretto-devel wget unzip amazon-efs-utils jq aws-cli

# Create Sonar user and directories
sudo groupadd -g 5000 sonar
sudo useradd -u 1001 -g 5000 -m sonar

# Mount EFS access points
#EFS_FS_ID -> EFS ID
#DATA_AP_ID -> Access point for /data
#EXT_AP_ID -> Access point for /extensions

# Download and install SonarQube
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.2.1.78527.zip
unzip sonarqube-10.2.1.78527.zip
mv sonarqube-10.2.1.78527 sonarqube
sudo chown -R sonar:sonar /opt/sonarqube

# Mount data
sudo echo "fs-0a002115942877480:/ /opt/sonarqube/data efs _netdev,tls,accesspoint=fsap-08d6a443695172267,iam 0 0" >> /etc/fstab
sudo echo "fs-0a002115942877480:/ /opt/sonarqube/extensions efs _netdev,tls,accesspoint=fsap-01e35638db8c28018,iam 0 0" >> /etc/fstab
sudo mount -a

# Fetch DB credentials from Secrets Manager
SECRET_ARN="test-dev-sonarqube-db/postgres-master-creds--DUcU8C"
DB_HOST="test-dev-sonarqube-db.c1d1cwdzq6rm.ap-southeast-1.rds.amazonaws.com:5432"
DB_NAME="postgres"

CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id $SECRET_ARN --query SecretString --output text)
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

sudo sysctl -w vm.max_map_count=262144

# Start SonarQube
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube