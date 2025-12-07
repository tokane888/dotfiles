deb_build:
	apt install -y apt-utils aptly build-essential cdbs debhelper debootstrap devscripts dh-make pbuilder quilt
test_tools:
	npm i -g bats
mydns:
	cp option/mydns/mydns.service /etc/systemd/system/
	cp option/mydns/mydns.timer /etc/systemd/system/
	systemctl start mydns.timer
	systemctl enable mydns.timer
