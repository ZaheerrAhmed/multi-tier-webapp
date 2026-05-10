#!/bin/bash
# Full automated provisioning — runs all setup steps in correct order
# Usage: bash scripts/provision-all.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}WARN:${NC} $1"; }
die()  { echo -e "${RED}ERROR:${NC} $1"; exit 1; }

command -v vagrant &>/dev/null || die "Vagrant not installed"
command -v VBoxManage &>/dev/null || die "VirtualBox not installed"

cd "$(dirname "$0")/../vagrant/Manual_provisioning_WinMacIntel"

log "Starting all VMs..."
vagrant up

log "Step 1/5 — Provisioning MySQL (db01)..."
vagrant ssh db01 -c "
  sudo dnf update -y -q
  sudo dnf install -y -q epel-release
  sudo dnf install -y -q git mariadb-server
  sudo systemctl enable --now mariadb
  sudo mysql -u root -e \"
    CREATE DATABASE IF NOT EXISTS accounts;
    GRANT ALL ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
    GRANT ALL ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
    FLUSH PRIVILEGES;
  \"
  cd /tmp && git clone -b local https://github.com/hkhcoder/vprofile-project.git 2>/dev/null || true
  mysql -u root accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql 2>/dev/null || true
  sudo systemctl enable --now firewalld
  sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent -q
  sudo firewall-cmd --reload -q
  sudo systemctl restart mariadb
  echo 'MySQL provisioning complete'
"

log "Step 2/5 — Provisioning Memcached (mc01)..."
vagrant ssh mc01 -c "
  sudo dnf update -y -q
  sudo dnf install -y -q epel-release memcached
  sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
  sudo systemctl enable --now memcached
  sudo systemctl enable --now firewalld
  sudo firewall-cmd --zone=public --add-port=11211/tcp --permanent -q
  sudo firewall-cmd --zone=public --add-port=11111/udp --permanent -q
  sudo firewall-cmd --reload -q
  echo 'Memcached provisioning complete'
"

log "Step 3/5 — Provisioning RabbitMQ (rmq01)..."
vagrant ssh rmq01 -c "
  sudo dnf update -y -q
  sudo dnf install -y -q epel-release wget
  sudo dnf install -y -q centos-release-rabbitmq-38
  sudo dnf --enablerepo=centos-rabbitmq-38 install -y -q rabbitmq-server
  sudo sh -c 'echo \"[{rabbit, [{loopback_users, []}]}].\" > /etc/rabbitmq/rabbitmq.config'
  sudo systemctl enable --now rabbitmq-server
  sudo rabbitmqctl add_user test test 2>/dev/null || true
  sudo rabbitmqctl set_user_tags test administrator
  sudo rabbitmqctl set_permissions -p / test '.*' '.*' '.*'
  sudo systemctl enable --now firewalld
  sudo firewall-cmd --zone=public --add-port=5672/tcp --permanent -q
  sudo firewall-cmd --reload -q
  echo 'RabbitMQ provisioning complete'
"

log "Step 4/5 — Provisioning Tomcat + App (app01)..."
vagrant ssh app01 -c "
  sudo dnf update -y -q
  sudo dnf install -y -q epel-release java-17-openjdk java-17-openjdk-devel git wget unzip
  cd /tmp
  wget -q https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
  tar xzf apache-tomcat-10.1.26.tar.gz
  sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat 2>/dev/null || true
  sudo cp -r /tmp/apache-tomcat-10.1.26/* /usr/local/tomcat/
  sudo chown -R tomcat:tomcat /usr/local/tomcat
  sudo tee /etc/systemd/system/tomcat.service > /dev/null <<'EOF'
[Unit]
Description=Tomcat
After=network.target
[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always
[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  wget -q https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
  sudo unzip -q apache-maven-3.9.9-bin.zip -d /usr/local/
  sudo mv /usr/local/apache-maven-3.9.9 /usr/local/maven3.9
  git clone -b main https://github.com/ZaheerrAhmed/multi-tier-webapp.git /tmp/opsboard 2>/dev/null || true
  cd /tmp/opsboard
  sudo MAVEN_OPTS='-Xmx400m' /usr/local/maven3.9/bin/mvn install -q
  sudo rm -rf /usr/local/tomcat/webapps/ROOT*
  sudo cp target/opsboard-v1.war /usr/local/tomcat/webapps/ROOT.war
  sudo chown tomcat:tomcat /usr/local/tomcat/webapps/ROOT.war
  sudo systemctl enable --now firewalld
  sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent -q
  sudo firewall-cmd --reload -q
  sudo systemctl start tomcat
  echo 'Tomcat provisioning complete'
"

log "Step 5/5 — Provisioning Nginx (web01)..."
vagrant ssh web01 -c "
  sudo apt-get update -qq
  sudo apt-get install -y -qq nginx
  sudo tee /etc/nginx/sites-available/opsboard > /dev/null <<'EOF'
upstream opsboard {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://opsboard;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo ln -sf /etc/nginx/sites-available/opsboard /etc/nginx/sites-enabled/opsboard
  sudo systemctl restart nginx
  echo 'Nginx provisioning complete'
"

echo ""
log "All services provisioned! Access the app at http://192.168.56.11"
log "Login: admin_vp / admin_vp"
