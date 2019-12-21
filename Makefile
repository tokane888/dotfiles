deb_build:
	apt install -y build-essential devscripts cdbs dh-make quilt debhelper devscripts apt-utils aptly pbuilder debootstrap
rpm_build:
	yum install -y gcc rpm-build rpm-devel rpmlint make python bash coreutils diffutils patch rpmdevtools createrepo
test_tools:
	npm i -g bats