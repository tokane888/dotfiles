deb_build:
	apt install -y apt-utils aptly build-essential cdbs debhelper debootstrap devscripts dh-make pbuilder quilt
rpm_build:
	yum install -y bash coreutils diffutils createrepo gcc make patch python rpmdevtools rpmlint rpm-build rpm-devel
test_tools:
	npm i -g bats