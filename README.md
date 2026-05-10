# Multi-Tier Web Application — OpsBoard

A production-style multi-tier web application provisioned locally with Vagrant and VirtualBox.
Demonstrates a full DevOps stack: reverse proxy, application server, database, caching, and message brokering — all wired together manually so you understand every layer.

**Author:** Zaheer Ahmad — [github.com/ZaheerrAhmed](https://github.com/ZaheerrAhmed)

---

## Architecture

```
Browser
   │
   ▼
[ Nginx ]  ← web01 | Ubuntu | 192.168.56.11   (reverse proxy)
   │
   ▼
[ Tomcat ] ← app01 | CentOS 9 | 192.168.56.12  (application server)
   │
   ├──▶ [ MySQL ]     ← db01  | CentOS 9 | 192.168.56.15  (database)
   ├──▶ [ Memcached ] ← mc01  | CentOS 9 | 192.168.56.14  (cache)
   └──▶ [ RabbitMQ ]  ← rmq01 | CentOS 9 | 192.168.56.13  (message broker)
```

---

## Prerequisites

Install these on your host machine before starting:

| Tool | Version | Download |
|---|---|---|
| VirtualBox | 6.1+ | https://www.virtualbox.org/wiki/Downloads |
| Vagrant | 2.3+ | https://developer.hashicorp.com/vagrant/downloads |
| Git Bash | latest | https://git-scm.com/downloads |
| JDK | 17 | https://adoptium.net |
| Maven | 3.9 | https://maven.apache.org/download.cgi |

Install the Vagrant hostmanager plugin (required — manages `/etc/hosts` across all VMs):

```bash
vagrant plugin install vagrant-hostmanager
```

---

## VM Setup

```bash
# Clone the repo
git clone https://github.com/ZaheerrAhmed/multi-tier-webapp.git
cd multi-tier-webapp

# Start all VMs (takes 10–20 min first time)
cd vagrant/Manual_provisioning_WinMacIntel
vagrant up
```

> If `vagrant up` stops in the middle, just run it again — it resumes where it left off.

Verify all VMs are running:

```bash
vagrant status
```

Expected output:
```
db01   running (virtualbox)
mc01   running (virtualbox)
rmq01  running (virtualbox)
app01  running (virtualbox)
web01  running (virtualbox)
```

---

## Provisioning — Follow This Order

```
1. MySQL  →  2. Memcached  →  3. RabbitMQ  →  4. Tomcat  →  5. Nginx
```

---

### 1. MySQL Setup (db01)

```bash
vagrant ssh db01
```

```bash
# Update OS
sudo dnf update -y
sudo dnf install epel-release -y

# Install MariaDB
sudo dnf install git mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure installation (set root password: admin123)
sudo mysql_secure_installation
# → Set root password: Y  →  Password: admin123
# → Remove anonymous users: Y
# → Disallow root login remotely: N
# → Remove test database: Y
# → Reload privilege tables: Y

# Create database and user
sudo mysql -u root -padmin123 <<EOF
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
EXIT;
EOF

# Import database schema
cd /tmp
git clone -b local https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql

# Verify tables imported
mysql -u root -padmin123 accounts -e "show tables;"

# Firewall — allow port 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
```

---

### 2. Memcached Setup (mc01)

```bash
vagrant ssh mc01
```

```bash
sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install memcached -y

sudo systemctl start memcached
sudo systemctl enable memcached

# Listen on all interfaces
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

# Firewall — allow ports 11211 (TCP) and 11111 (UDP)
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=11211/tcp --permanent
sudo firewall-cmd --zone=public --add-port=11111/udp --permanent
sudo firewall-cmd --reload

sudo memcached -p 11211 -U 11111 -u memcached -d
```

---

### 3. RabbitMQ Setup (rmq01)

```bash
vagrant ssh rmq01
```

```bash
sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf install wget -y
sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server

# Create user and set permissions
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
sudo systemctl restart rabbitmq-server

# Firewall — allow port 5672
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=5672/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server
```

---

### 4. Tomcat + App Setup (app01)

```bash
vagrant ssh app01
```

#### Install Java and Tomcat

```bash
sudo dnf update -y
sudo dnf install epel-release -y
sudo dnf -y install java-17-openjdk java-17-openjdk-devel git wget

# Download and extract Tomcat 10
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz
tar xzvf apache-tomcat-10.1.26.tar.gz

# Create tomcat user and install
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
sudo cp -r /tmp/apache-tomcat-10.1.26/* /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat
```

#### Create Tomcat systemd service

```bash
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
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
sudo systemctl start tomcat
sudo systemctl enable tomcat

# Firewall — allow port 8080
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

#### Build and Deploy the Application

```bash
# Install Maven
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip
unzip apache-maven-3.9.9-bin.zip
sudo cp -r apache-maven-3.9.9 /usr/local/maven3.9

# Clone source code
cd /tmp
git clone -b main https://github.com/ZaheerrAhmed/multi-tier-webapp.git
cd multi-tier-webapp

# Build (stop Tomcat first to free memory)
sudo systemctl stop tomcat
sudo MAVEN_OPTS="-Xmx400m" /usr/local/maven3.9/bin/mvn install

# Deploy WAR
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/opsboard-v1.war /usr/local/tomcat/webapps/ROOT.war
sudo chown tomcat:tomcat /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat

# Wait ~30 seconds for Tomcat to extract the WAR, then verify
sudo ls /usr/local/tomcat/webapps/ROOT/
# Should show: WEB-INF  resources  META-INF
```

> **Important:** Always stop Tomcat before running Maven build on this VM (800MB RAM). If you don't, the build will fail with `OutOfMemoryError`.

---

### 5. Nginx Setup (web01)

```bash
vagrant ssh web01
sudo -i
```

```bash
apt update && apt upgrade -y
apt install nginx -y

# Create reverse proxy config
cat > /etc/nginx/sites-available/vproapp <<EOF
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOF

# Enable site
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

systemctl restart nginx
```

---

## Access the Application

Open your browser and go to:

```
http://192.168.56.11
```

**Login credentials:**

| Username | Password |
|---|---|
| `admin_vp` | `admin_vp` |

---

## Troubleshooting

### App shows default Tomcat page
The old ROOT directory is blocking WAR extraction. Fix:
```bash
vagrant ssh app01
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT
sudo systemctl start tomcat
```

### 502 Bad Gateway on Nginx
Tomcat isn't reachable. From web01, test:
```bash
curl -I http://app01:8080
```
If it fails, check firewall on app01:
```bash
vagrant ssh app01
sudo firewall-cmd --list-ports   # should show 8080/tcp
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

### Login fails / database error
Check DB port is open on db01:
```bash
vagrant ssh db01
sudo firewall-cmd --list-ports   # should show 3306/tcp
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
```

### Maven build fails with OutOfMemoryError
Always stop Tomcat before building:
```bash
sudo systemctl stop tomcat
sudo MAVEN_OPTS="-Xmx400m" /usr/local/maven3.9/bin/mvn install
```

---

## VM Management

```bash
# Stop all VMs (saves RAM)
vagrant halt

# Start all VMs again
vagrant up

# SSH into any VM
vagrant ssh db01
vagrant ssh mc01
vagrant ssh rmq01
vagrant ssh app01
vagrant ssh web01

# Destroy all VMs (caution: deletes everything)
vagrant destroy
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Reverse Proxy | Nginx |
| Application Server | Apache Tomcat 10 |
| Application Framework | Spring MVC + Spring Security + JPA |
| Build Tool | Maven 3.9 |
| Database | MariaDB (MySQL compatible) |
| Caching | Memcached |
| Message Broker | RabbitMQ |
| Infrastructure | Vagrant + VirtualBox |
| OS | Ubuntu 22.04 (web01), CentOS Stream 9 (all others) |
| Language | Java 17 |

---

## Project Goals

Each project in this series targets a different tool or concept:

- Manual provisioning with Vagrant (this project)
- Automated provisioning with shell scripts
- Ansible playbooks
- Docker + Docker Compose
- Kubernetes deployment
- CI/CD with Jenkins
- AWS lift-and-shift
- AWS cloud-native refactor
- Terraform infrastructure
- Monitoring with Prometheus + Grafana
- ... and 90 more

Follow along: [github.com/ZaheerrAhmed](https://github.com/ZaheerrAhmed)
