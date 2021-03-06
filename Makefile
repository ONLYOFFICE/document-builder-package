PWD := $(shell pwd)
CD := cd
TOUCH := touch
MKDIR := mkdir -p
CP := cp -rf -t
RM := rm -rfv
CURL := curl -fLo

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
	TAR_ARCH := x86_64
	ARCHITECTURE := 64
endif
ifneq ($(filter %86,$(UNAME_M)),)
	RPM_ARCH := i386
	DEB_ARCH := i386
	WIN_ARCH := x86
	TAR_ARCH := i386
	ARCHITECTURE := 32
endif

ifeq ($(OS),Windows_NT)
	PLATFORM := win
	SRC ?= ../build_tools/out/win_$(ARCHITECTURE)/$(COMPANY_NAME)/$(PRODUCT_NAME)/*
	PACKAGE_VERSION := $(PRODUCT_VERSION).$(BUILD_NUMBER)
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		PLATFORM := linux
		SRC ?= ../build_tools/out/linux_$(ARCHITECTURE)/$(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)/*
		DB_PREFIX := $(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)
		PACKAGE_VERSION := $(PRODUCT_VERSION)-$(BUILD_NUMBER)
	endif
endif

RPM_BUILD_DIR := $(PWD)/rpm/builddir
DEB_BUILD_DIR := $(PWD)/deb
TAR_BUILD_DIR := $(PWD)/tar
EXE_BUILD_DIR = exe
ZIP_BUILD_DIR = zip

RPM_PACKAGE_DIR := $(RPM_BUILD_DIR)/RPMS/$(RPM_ARCH)
DEB_PACKAGE_DIR := .
TAR_PACKAGE_DIR = $(TAR_BUILD_DIR)

S3_BUCKET ?= repo-doc-onlyoffice-com
RELEASE_BRANCH ?= unstable

RPM := $(RPM_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION).$(RPM_ARCH).rpm
DEB := $(DEB_PACKAGE_DIR)/$(PACKAGE_NAME)_$(PACKAGE_VERSION)_$(DEB_ARCH).deb
TAR := $(TAR_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(TAR_ARCH).tar.gz
EXE := $(EXE_BUILD_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(WIN_ARCH).exe
ZIP := $(ZIP_BUILD_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(WIN_ARCH).zip

RPM_URI := $(COMPANY_NAME_LOW)/$(RELEASE_BRANCH)/centos/$(notdir $(RPM))
DEB_URI := $(COMPANY_NAME_LOW)/$(RELEASE_BRANCH)/ubuntu/$(notdir $(DEB))
TAR_URI := $(COMPANY_NAME_LOW)/$(RELEASE_BRANCH)/linux/$(notdir $(TAR))
EXE_URI := $(COMPANY_NAME_LOW)/$(RELEASE_BRANCH)/windows/$(notdir $(EXE))
ZIP_URI := $(COMPANY_NAME_LOW)/$(RELEASE_BRANCH)/windows/$(notdir $(ZIP))

DEPLOY_JSON = deploy.json

CORE_PATH := ../core

DOCUMENTBUILDER := common/documentbuilder/home
DOCUMENTBUILDER_BIN := common/documentbuilder/bin

ISCC := iscc 
ISCC_PARAMS += //Qp
ISCC_PARAMS += //S"byparam=signtool.exe sign /v /n $(firstword $(PUBLISHER_NAME)) /t http://timestamp.digicert.com \$$f"
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

.PHONY: all clean deb rpm tar exe zip deploy deploy-deb deploy-rpm deploy-tar deploy-exe deploy-zip

all: deb rpm tar

rpm: $(RPM)

deb: $(DEB)

tar: $(TAR)

exe: $(EXE)

zip: $(ZIP)

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
		$(TAR_BUILD_DIR)\
		$(ZIP_BUILD_DIR)\
		$(DEPLOY_JSON)\
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
	--define '_binary_payload w7.xzdio' \
	$(PACKAGE_NAME).spec

$(DEB): $(DEB_DEPS) $(LINUX_DEPS) $(PRODUCT_NAME_LOW)
	$(CD) deb && dpkg-buildpackage -b -uc -us

$(EXE): $(WIN_DEPS) $(ISXDL)
	cd exe && $(ISCC) $(ISCC_PARAMS) $(PACKAGE_NAME).iss

$(ISXDL):
	$(TOUCH) $(ISXDL) && \
	for i in {1..5}; do \
		$(CURL) $(ISXDL) https://raw.githubusercontent.com/jrsoftware/ispack/is-5_6_1/isxdlfiles/isxdl.dll && \
		break || \
		sleep 30s; \
	done

$(TAR): $(PRODUCT_NAME_LOW)
	$(MKDIR) $(dir $@) $(TAR_BUILD_DIR)/documentbuilder
	$(CP) $(TAR_BUILD_DIR)/documentbuilder $(DOCUMENTBUILDER)/*
	tar -czf $@ --owner=root --group=root -C $(TAR_BUILD_DIR) documentbuilder

$(ZIP): $(PRODUCT_NAME_LOW)
	$(MKDIR) $(dir $@)
	7z a -y $@ ./$(DOCUMENTBUILDER)/*

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

deploy-deb: $(DEB)
	aws s3 cp --no-progress --acl public-read \
		$(DEB) s3://$(S3_BUCKET)/$(DEB_URI)

deploy-rpm: $(RPM)
	aws s3 cp --no-progress --acl public-read \
		$(RPM) s3://$(S3_BUCKET)/$(RPM_URI)

deploy-tar: $(TAR)
	aws s3 cp --no-progress --acl public-read \
		$(TAR) s3://$(S3_BUCKET)/$(TAR_URI)

deploy-exe: $(EXE)
	aws s3 cp --no-progress --acl public-read \
		$(EXE) s3://$(S3_BUCKET)/$(EXE_URI)

deploy-zip: $(ZIP)
	aws s3 cp --no-progress --acl public-read \
		$(ZIP) s3://$(S3_BUCKET)/$(ZIP_URI)

comma := ,
json_edit = cp -f $(1) $(1).tmp; jq $(2) $(1).tmp > $(1); rm -f $(1).tmp

$(DEPLOY_JSON):
	echo '{}' > $@
	$(call json_edit, $@, '. + { \
		product:  "$(PRODUCT_NAME_LOW)"$(comma) \
		version:  "$(PRODUCT_VERSION)"$(comma) \
		build:    "$(BUILD_NUMBER)" \
	}')
ifeq ($(PLATFORM), win)
	$(call json_edit, $@, '.items += [{ \
		platform: "windows"$(comma) \
		title:    "Windows 64-bit"$(comma) \
		path:     "$(EXE_URI)" \
	}]')
	$(call json_edit, $@, '.items += [{ \
		platform: "windows"$(comma) \
		title:    "Windows Portable 64-bit"$(comma) \
		path:     "$(ZIP_URI)" \
	}]')
endif
ifeq ($(PLATFORM), linux)
	$(call json_edit, $@, '.items += [{ \
		platform: "ubuntu"$(comma) \
		title:    "Debian 8 9 10$(comma) Ubuntu 14 16 18 20 and derivatives"$(comma) \
		path:     "$(DEB_URI)" \
	}]')
	$(call json_edit, $@, '.items += [{ \
		platform: "centos"$(comma) \
		title:    "Centos 7$(comma) Redhat 7$(comma) Fedora latest and derivatives"$(comma) \
		path:     "$(RPM_URI)" \
	}]')
# 	$(call json_edit, $@, '.items += [{ \
# 		platform: "linux"$(comma) \
# 		title:    "Linux portable"$(comma) \
# 		path:     "$(TAR_URI)" \
# 	}]')
endif

ifeq ($(PLATFORM),linux)
DEPLOY += deploy-deb
DEPLOY += deploy-rpm
# DEPLOY += deploy-tar
else ifeq ($(PLATFORM),win)
DEPLOY += deploy-exe
DEPLOY += deploy-zip
endif

deploy: $(DEPLOY) $(DEPLOY_JSON)
