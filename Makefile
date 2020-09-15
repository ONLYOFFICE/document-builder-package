PWD := $(shell pwd)
CD := cd
TOUCH := touch
MKDIR := mkdir -p
CP := cp -rf -t
RM := rm -rfv
CURL := curl -L -f --retry 5 --retry-all-errors -o

COMPANY_NAME ?= ONLYOFFICE
PRODUCT_NAME ?= DocumentBuilder

COMPANY_NAME_LOW = $(shell echo $(COMPANY_NAME) | tr A-Z a-z)
PRODUCT_NAME_LOW = $(shell echo $(PRODUCT_NAME) | tr A-Z a-z)

PUBLISHER_NAME ?= Ascensio System SIA
PUBLISHER_URL ?= http://onlyoffice.com
SUPPORT_URL ?= http://support.onlyoffice.com
SUPPORT_MAIL ?= support@onlyoffice.com

PRODUCT_VERSION ?= 0.0.0
BUILD_NUMBER ?= 0

BRANDING_DIR ?= ./branding

PACKAGE_NAME := $(COMPANY_NAME_LOW)-$(PRODUCT_NAME_LOW)

UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
	RPM_ARCH := x86_64
	DEB_ARCH := amd64
	WIN_ARCH := x64
	ARCH_SUFFIX := x64
	ARCHITECTURE := 64
endif
ifneq ($(filter %86,$(UNAME_M)),)
	RPM_ARCH := i386
	DEB_ARCH := i386
	WIN_ARCH := x86
	ARCH_SUFFIX := x86
	ARCHITECTURE := 32
endif

ifeq ($(OS),Windows_NT)
	PLATFORM := win
	EXEC_EXT := .exe
	SHELL_EXT := .bat
	SHARED_EXT := .dll
	ARCH_EXT := .zip
	SRC ?= ../build_tools/out/win_$(ARCHITECTURE)/$(COMPANY_NAME)/$(PRODUCT_NAME)/*
	PACKAGE_VERSION := $(PRODUCT_VERSION).$(BUILD_NUMBER)
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
		SHARED_EXT := .so*
		SHELL_EXT := .sh
		ARCH_EXT := .tar.gz
		SRC ?= ../build_tools/out/linux_$(ARCHITECTURE)/$(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)/*
		DB_PREFIX := $(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)
		PACKAGE_VERSION := $(PRODUCT_VERSION)-$(BUILD_NUMBER)
	endif
endif

ARCH_PACKAGE_DIR := ..

RPM_BUILD_DIR := $(PWD)/rpm/builddir
DEB_BUILD_DIR := $(PWD)/deb
EXE_BUILD_DIR = exe

RPM_PACKAGE_DIR := $(RPM_BUILD_DIR)/RPMS/$(RPM_ARCH)
DEB_PACKAGE_DIR := .

ARCH_REPO := $(PWD)/repo-arch
ARCH_REPO_DATA := $(ARCH_REPO)/$(PRODUCT_NAME_LOW)-$(PRODUCT_VERSION)-$(ARCH_SUFFIX)$(ARCH_EXT)

REPO_NAME := repo
DEB_REPO := $(PWD)/$(REPO_NAME)
DEB_REPO_DATA := $(DEB_REPO)/Packages.gz

RPM_REPO := $(PWD)/repo-rpm
RPM_REPO_DATA := $(RPM_REPO)/repodata

EXE_REPO := repo-exe
EXE_REPO_DATA := $(EXE_REPO)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(WIN_ARCH).exe

RPM_REPO_OS_NAME := centos
RPM_REPO_OS_VER := 7
RPM_REPO_DIR := $(RPM_REPO_OS_NAME)/$(RPM_REPO_OS_VER)

DEB_REPO_OS_NAME := ubuntu
DEB_REPO_OS_VER := trusty
DEB_REPO_DIR := $(DEB_REPO_OS_NAME)/$(DEB_REPO_OS_VER)

EXE_REPO_DIR = windows

ARCH_REPO_DIR := linux

INDEX_HTML := index.html

S3_BUCKET ?= repo-doc-onlyoffice-com

ifeq ($(OS),Windows_NT)
	ARCH_REPO_DIR := $(EXE_REPO_DIR)
	DEPLOY := $(EXE_REPO_DATA) $(INDEX_HTML)
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		DEPLOY := $(RPM_REPO_DATA) $(DEB_REPO_DATA) $(INDEX_HTML)
	endif
endif

ARCHIVE := $(ARCH_PACKAGE_DIR)/$(PRODUCT_NAME_LOW)-$(PRODUCT_VERSION)-$(ARCH_SUFFIX)$(ARCH_EXT)
RPM := $(RPM_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION).$(RPM_ARCH).rpm
DEB := $(DEB_PACKAGE_DIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(DEB_ARCH).deb
EXE := $(EXE_BUILD_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(WIN_ARCH).exe

CORE_PATH := ../core

DOCUMENTBUILDER := common/documentbuilder/home
DOCUMENTBUILDER_BIN := common/documentbuilder/bin

ISCC := iscc 
ISCC_PARAMS += //Qp
ISCC_PARAMS += //S"byparam=signtool.exe sign /v /n $(firstword $(PUBLISHER_NAME)) /t http://timestamp.verisign.com/scripts/timstamp.dll \$$f"
ISCC_PARAMS += //DsAppVerShort=$(PRODUCT_VERSION)
ISCC_PARAMS += //DsAppBuildNumber=$(BUILD_NUMBER)
ifdef ENABLE_SIGNING
ISCC_PARAMS += //DENABLE_SIGNING=1
endif

ISXDL = $(EXE_BUILD_DIR)/scripts/isxdl/isxdl.dll

LINUX_DEPS += common/documentbuilder/bin/documentbuilder
LINUX_DEPS += common/documentbuilder/bin/$(PACKAGE_NAME)

DEB_DEPS += deb/debian/changelog
DEB_DEPS += deb/debian/config
DEB_DEPS += deb/debian/control
DEB_DEPS += deb/debian/copyright
DEB_DEPS += deb/debian/postinst
DEB_DEPS += deb/debian/postrm
DEB_DEPS += deb/debian/rules
DEB_DEPS += deb/debian/$(PACKAGE_NAME).install

RPM_DEPS += rpm/$(PACKAGE_NAME).spec

WIN_DEPS += exe/$(PACKAGE_NAME).iss

M4_PARAMS += -D M4_COMPANY_NAME=$(COMPANY_NAME)
M4_PARAMS += -D M4_PRODUCT_NAME=$(PRODUCT_NAME)
M4_PARAMS += -D M4_PACKAGE_NAME=$(PACKAGE_NAME)
M4_PARAMS += -D M4_PACKAGE_VERSION=$(PACKAGE_VERSION)
M4_PARAMS += -D M4_DB_PREFIX=$(DB_PREFIX)
M4_PARAMS += -D M4_DEB_ARCH=$(DEB_ARCH)
M4_PARAMS += -D M4_RPM_ARCH=$(RPM_ARCH)
M4_PARAMS += -D M4_WIN_ARCH=$(WIN_ARCH)
M4_PARAMS += -D M4_PUBLISHER_NAME='$(PUBLISHER_NAME)'
M4_PARAMS += -D M4_PUBLISHER_URL='$(PUBLISHER_URL)'
M4_PARAMS += -D M4_SUPPORT_MAIL='$(SUPPORT_MAIL)'
M4_PARAMS += -D M4_SUPPORT_URL='$(SUPPORT_URL)'
M4_PARAMS += -D M4_BRANDING_DIR='$(abspath $(BRANDING_DIR))'
M4_PARAMS += -D M4_S3_BUCKET=$(S3_BUCKET)

ifeq ($(OS),Windows_NT)
	M4_PARAMS += -D M4_EXE_URI="$(EXE_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(WIN_ARCH)/$(notdir $(EXE))"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		M4_PARAMS += -D M4_DEB_URI="$(DEB_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(DEB_ARCH)/$(REPO_NAME)/$(notdir $(DEB))"
		M4_PARAMS += -D M4_RPM_URI="$(RPM_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(RPM_ARCH)/$(notdir $(RPM))"
	endif
endif

.PHONY: all clean deb rpm exe deploy

all: deb rpm arch

arch: $(ARCHIVE)

rpm: $(RPM)

deb: $(DEB)

exe: $(EXE)

clean:
	$(RM) $(LINUX_DEPS)\
		$(DOCUMENTBUILDER)\
		$(DEB_DEPS)\
		$(DEB_BUILD_DIR)/debian/.debhelper\
		$(DEB_BUILD_DIR)/debian/$(PACKAGE_NAME)\
		$(DEB_BUILD_DIR)/debian/files\
		$(DEB_BUILD_DIR)/debian/*.debhelper.log\
		$(DEB_BUILD_DIR)/debian/*.postrm.debhelper\
		$(DEB_BUILD_DIR)/debian/*.substvars\
		$(DEB_PACKAGE_DIR)/*.deb\
		$(DEB_PACKAGE_DIR)/*.changes\
		$(DEB_PACKAGE_DIR)/*.buildinfo\
		$(RPM_BUILD_DIR)\
		$(EXE_BUILD_DIR)/*.exe\
		$(ISXDL)\
		$(VCREDIST)\
		$(ARCH_PACKAGE_DIR)/*$(ARCH_EXT)\
		$(ARCH_REPO)\
		$(DEB_REPO)\
		$(RPM_REPO)\
		$(EXE_REPO)\
		$(INDEX_HTML)\
		$(PRODUCT_NAME_LOW)

$(PRODUCT_NAME_LOW):
	$(MKDIR) $(DOCUMENTBUILDER)
	$(CP) $(DOCUMENTBUILDER) $(SRC)

# 	echo "Done" > $@

$(RPM): $(RPM_DEPS) $(LINUX_DEPS) $(PRODUCT_NAME_LOW)
	$(CD) rpm && rpmbuild -bb \
	--define '_topdir $(RPM_BUILD_DIR)' \
	--define '_package_name $(PACKAGE_NAME)' \
	--define '_product_version $(PRODUCT_VERSION)' \
	--define '_build_number $(BUILD_NUMBER)' \
	--define '_publisher_name $(PUBLISHER_NAME)' \
	--define '_publisher_url $(PUBLISHER_URL)' \
	--define '_support_mail $(SUPPORT_MAIL)' \
	--define '_rpm_arch $(RPM_ARCH)' \
	--define '_db_prefix $(DB_PREFIX)' \
	$(PACKAGE_NAME).spec

$(DEB): $(DEB_DEPS) $(LINUX_DEPS) $(PRODUCT_NAME_LOW)
	$(CD) deb && dpkg-buildpackage -b -uc -us

$(EXE): $(WIN_DEPS) $(ISXDL)
	cd exe && $(ISCC) $(ISCC_PARAMS) $(PACKAGE_NAME).iss

$(ISXDL):
	$(TOUCH) $(ISXDL) && \
	$(CURL) $(ISXDL) https://raw.githubusercontent.com/jrsoftware/ispack/is-5_6_1/isxdlfiles/isxdl.dll

$(RPM_REPO_DATA): $(RPM)
	$(RM) $(RPM_REPO)
	$(MKDIR) $(RPM_REPO)

	$(CP) $(RPM_REPO) $(RPM)
	createrepo -v $(RPM_REPO)

	aws s3 sync \
		$(RPM_REPO) \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(RPM_ARCH)/ \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(RPM_ARCH)/  \
		s3://repo-doc-onlyoffice-com/$(RPM_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/latest/$(RPM_ARCH)/ \
		--acl public-read --delete

$(DEB_REPO_DATA): $(DEB)
	$(RM) $(DEB_REPO)
	$(MKDIR) $(DEB_REPO)

	$(CP) $(DEB_REPO) $(DEB)
	dpkg-scanpackages -m $(REPO_NAME) /dev/null | gzip -9c > $(DEB_REPO_DATA)

	aws s3 sync \
		$(DEB_REPO) \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(DEB_ARCH)/$(REPO_NAME) \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(DEB_ARCH)/$(REPO_NAME) \
		s3://repo-doc-onlyoffice-com/$(DEB_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/latest/$(DEB_ARCH)/$(REPO_NAME) \
		--acl public-read --delete

$(EXE_REPO_DATA): $(EXE)
	rm -rfv $(EXE_REPO)
	mkdir -p $(EXE_REPO)

	cp -rv $(EXE) $(EXE_REPO);

	aws s3 sync \
		$(EXE_REPO) \
		s3://repo-doc-onlyoffice-com/$(EXE_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(WIN_ARCH)/ \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(EXE_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(WIN_ARCH)/  \
		s3://repo-doc-onlyoffice-com/$(EXE_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/latest/$(WIN_ARCH)/ \
		--acl public-read --delete

$(ARCH_REPO_DATA): $(ARCHIVE)
	rm -rfv $(ARCH_REPO)
	mkdir -p $(ARCH_REPO)

	cp -rv $(ARCHIVE) $(ARCH_REPO)

	aws s3 sync \
		$(ARCH_REPO) \
		s3://repo-doc-onlyoffice-com/$(ARCH_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(ARCH_SUFFIX)/ \
		--acl public-read --delete

	aws s3 sync \
		s3://repo-doc-onlyoffice-com/$(ARCH_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/$(PACKAGE_VERSION)/$(ARCH_SUFFIX)/  \
		s3://repo-doc-onlyoffice-com/$(ARCH_REPO_DIR)/$(PACKAGE_NAME)/origin/$(GIT_BRANCH)/latest/$(ARCH_SUFFIX)/ \
		--acl public-read --delete

%-$(ARCH_SUFFIX).tar.gz : %
	tar -zcvf $@ $<

%-$(ARCH_SUFFIX).zip : %
	7z a -y $@ $<

% : %.sh.m4
	m4 $(M4_PARAMS)	$< > $@
	chmod +x $@

% : %.m4
	m4 $(M4_PARAMS)	$< > $@

common/documentbuilder/bin/$(PACKAGE_NAME) : common/documentbuilder/bin/documentbuilder
	ln -srf $< $@

deb/debian/$(PACKAGE_NAME).install : deb/debian/package.install
	mv -f $< $@

rpm/$(PACKAGE_NAME).spec : rpm/package.spec
	cp -f $< $@

exe/$(PACKAGE_NAME).iss : exe/package.iss
	mv -f $< $@

deploy: $(DEPLOY)
