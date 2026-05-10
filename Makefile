.PHONY: up down ssh-app ssh-db ssh-web build deploy health clean

VAGRANT_DIR = vagrant/Manual_provisioning_WinMacIntel

up:
	cd $(VAGRANT_DIR) && vagrant up

down:
	cd $(VAGRANT_DIR) && vagrant halt

destroy:
	cd $(VAGRANT_DIR) && vagrant destroy -f

status:
	cd $(VAGRANT_DIR) && vagrant status

ssh-web:
	cd $(VAGRANT_DIR) && vagrant ssh web01

ssh-app:
	cd $(VAGRANT_DIR) && vagrant ssh app01

ssh-db:
	cd $(VAGRANT_DIR) && vagrant ssh db01

ssh-mc:
	cd $(VAGRANT_DIR) && vagrant ssh mc01

ssh-rmq:
	cd $(VAGRANT_DIR) && vagrant ssh rmq01

build:
	cd $(VAGRANT_DIR) && vagrant ssh app01 -c \
		"cd /tmp/opsboard && sudo MAVEN_OPTS='-Xmx400m' /usr/local/maven3.9/bin/mvn install -q"

deploy:
	cd $(VAGRANT_DIR) && vagrant ssh app01 -c \
		"sudo systemctl stop tomcat && \
		 sudo rm -rf /usr/local/tomcat/webapps/ROOT* && \
		 sudo cp /tmp/opsboard/target/opsboard-v1.war /usr/local/tomcat/webapps/ROOT.war && \
		 sudo chown tomcat:tomcat /usr/local/tomcat/webapps/ROOT.war && \
		 sudo systemctl start tomcat && \
		 echo 'Deployed successfully'"

health:
	bash scripts/health-check.sh

provision:
	bash scripts/provision-all.sh

open:
	@echo "App running at: http://192.168.56.11"
	@echo "Login: admin_vp / admin_vp"
