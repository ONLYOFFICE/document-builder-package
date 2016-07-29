COMPANY_NAME := onlyoffice
PRODUCT_NAME := documentbuilder
PACKAGE_NAME := $(COMPANY_NAME)-$(PRODUCT_NAME)
PACKAGE_VERSION := $(PRODUCT_VERSION)-$(BUILD_NUMBER)

RPM_ARCH := x86_64
DEB_ARCH := amd64

RPM_BUILD_DIR := $(PWD)/rpm/builddir
DEB_BUILD_DIR := $(PWD)/deb

RPM_PACKAGE_DIR := $(RPM_BUILD_DIR)/RPMS/$(RPM_ARCH)
DEB_PACKAGE_DIR := $(DEB_BUILD_DIR)

DEB_REPO := $(PWD)/repo
DEB_REPO_DATA := $(DEB_REPO)/Packages.gz

RPM_REPO := $(PWD)/repo-rpm
RPM_REPO_DATA := $(RPM_REPO)/repodata

RPM_REPO_OS_NAME := centos
RPM_REPO_OS_VER := 7
RPM_REPO_DIR := $(RPM_REPO_OS_NAME)/$(RPM_REPO_OS_VER)

DEB_REPO_OS_NAME := ubuntu
DEB_REPO_OS_VER := trusty
DEB_REPO_DIR := $(DEB_REPO_OS_NAME)/$(DEB_REPO_OS_VER)

RPM := $(RPM_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION).$(RPM_ARCH).rpm
DEB := $(DEB_PACKAGE_DIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(DEB_ARCH).deb

MKDIR := mkdir -p
RM := rm -rfv
CP := cp -rf -t
CD := cd

CORE_PATH := ../core

SRC += $(CORE_PATH)/build/linux_builder/builder/*

DEST := common/$(PRODUCT_NAME)/home

.PHONY: all clean deb deploy

all: deb rpm

rpm: $(RPM)

deb: $(DEB)

clean:
	$(RM) $(DEB_PACKAGE_DIR)/*.deb\
		$(DEB_PACKAGE_DIR)/*.changes\
		$(RPM_BUILD_DIR)\
		$(DEB_REPO)\
		$(RPM_REPO)\
		$(PRODUCT_NAME)

$(PRODUCT_NAME):
	$(MKDIR) $(DEST)
	$(CP) $(DEST) $(SRC)

	echo "Done" > $@

$(RPM):	$(PRODUCT_NAME)
	sed 's/{{PRODUCT_VERSION}}/'$(PRODUCT_VERSION)'/'  -i rpm/$(PACKAGE_NAME).spec
	sed 's/{{BUILD_NUMBER}}/'${BUILD_NUMBER}'/'  -i rpm/$(PACKAGE_NAME).spec

	$(CD) rpm && rpmbuild -bb --define "_topdir $(RPM_BUILD_DIR)" $(PACKAGE_NAME).spec

$(DEB): $(PRODUCT_NAME)
	sed 's/{{PACKAGE_VERSION}}/'$(PACKAGE_VERSION)'/'  -i deb/$(PACKAGE_NAME)/debian/changelog

	$(CD) deb/$(PACKAGE_NAME) && dpkg-buildpackage -b -uc -us

$(RPM_REPO_DATA): $(RPM)
	$(RM) $(RPM_REPO)
	$(MKDIR) $(RPM_REPO)

	$(CP) $(RPM_REPO) $(RPM)
	createrepo -v $(RPM_REPO)

	aws s3 sync \
		$(RPM_REPO) \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/$(PACKAGE_VERSION)/ \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/$(PACKAGE_VERSION)/  \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/latest/ \
		--acl public-read --delete

$(DEB_REPO_DATA): $(DEB)
	$(RM) $(DEB_REPO)
	$(MKDIR) $(DEB_REPO)

	$(CP) $(DEB_REPO) $(DEB)
	dpkg-scanpackages -m repo /dev/null | gzip -9c > $(DEB_REPO_DATA)

	aws s3 sync \
		$(DEB_REPO) \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/$(PACKAGE_VERSION)/repo \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/$(PACKAGE_VERSION)/repo \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/$(GIT_BRANCH)/latest/repo \
		--acl public-read --delete

deploy: $(DEB_REPO_DATA) $(RPM_REPO_DATA)
