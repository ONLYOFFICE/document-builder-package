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

BRANDING_DIR ?= .

PACKAGE_NAME := $(COMPANY_NAME_LOW)-$(PRODUCT_NAME_LOW)

UNAME_M ?= $(shell uname -m)
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
ifneq ($(filter aarch%,$(UNAME_M)),)
	RPM_ARCH := aarch64
	DEB_ARCH := arm64
	TAR_ARCH := aarch64
	ARCHITECTURE := arm64
endif

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	PLATFORM := linux
	SRC ?= ../build_tools/out/linux_$(ARCHITECTURE)/$(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)/*
	DB_PREFIX := $(COMPANY_NAME_LOW)/$(PRODUCT_NAME_LOW)
	PACKAGE_VERSION := $(PRODUCT_VERSION)-$(BUILD_NUMBER)
endif

RPM_BUILD_DIR := $(PWD)/rpm/builddir
TAR_BUILD_DIR := $(PWD)/tar

RPM_PACKAGE_DIR := $(RPM_BUILD_DIR)/RPMS/$(RPM_ARCH)
TAR_PACKAGE_DIR = $(TAR_BUILD_DIR)

DISTRIB_CODENAME=$(shell lsb_release -cs || echo "n/a")
ifeq ($(DISTRIB_CODENAME),trusty)
  RPM_RELEASE := el7
  DEB_RELEASE := jessie
  TAR_RELEASE := gcc4
else ifeq ($(DISTRIB_CODENAME),xenial)
  RPM_RELEASE := el8
  DEB_RELEASE := stretch
  TAR_RELEASE := gcc5
endif

RPM := $(RPM_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)$(RPM_RELEASE:%=.%).$(RPM_ARCH).rpm
DEB := deb/$(PACKAGE_NAME)_$(PACKAGE_VERSION)$(DEB_RELEASE:%=~%)_$(DEB_ARCH).deb
TAR := $(TAR_PACKAGE_DIR)/$(PACKAGE_NAME)-$(PACKAGE_VERSION)$(TAR_RELEASE:%=_%)-$(TAR_ARCH).tar.gz

DOCUMENTBUILDER := common/documentbuilder/home
DOCUMENTBUILDER_BIN := common/documentbuilder/bin

LINUX_DEPS += common/documentbuilder/bin/$(PACKAGE_NAME)

DEB_DEPS += deb/build/debian/source/format
DEB_DEPS += deb/build/debian/changelog
DEB_DEPS += deb/build/debian/compat
DEB_DEPS += deb/build/debian/config
DEB_DEPS += deb/build/debian/control
DEB_DEPS += deb/build/debian/copyright
DEB_DEPS += deb/build/debian/postinst
DEB_DEPS += deb/build/debian/postrm
DEB_DEPS += deb/build/debian/rules
DEB_DEPS += deb/build/debian/$(PACKAGE_NAME).install
DEB_DEPS += deb/build/debian/$(PACKAGE_NAME).links

RPM_DEPS += rpm/$(PACKAGE_NAME).spec

M4_PARAMS += -D M4_COMPANY_NAME=$(COMPANY_NAME)
M4_PARAMS += -D M4_PRODUCT_NAME=$(PRODUCT_NAME)
M4_PARAMS += -D M4_PACKAGE_NAME=$(PACKAGE_NAME)
M4_PARAMS += -D M4_PACKAGE_VERSION=$(PACKAGE_VERSION)$(DEB_RELEASE:%=~%)
M4_PARAMS += -D M4_DB_PREFIX=$(DB_PREFIX)
M4_PARAMS += -D M4_DEB_ARCH=$(DEB_ARCH)
M4_PARAMS += -D M4_RPM_ARCH=$(RPM_ARCH)
M4_PARAMS += -D M4_WIN_ARCH=$(WIN_ARCH)
M4_PARAMS += -D M4_PUBLISHER_NAME='$(PUBLISHER_NAME)'
M4_PARAMS += -D M4_PUBLISHER_URL='$(PUBLISHER_URL)'
M4_PARAMS += -D M4_SUPPORT_MAIL='$(SUPPORT_MAIL)'
M4_PARAMS += -D M4_SUPPORT_URL='$(SUPPORT_URL)'
M4_PARAMS += -D M4_BRANDING_DIR='$(abspath $(BRANDING_DIR))'

.PHONY: all clean deb rpm tar exe zip packages

all: deb rpm tar

rpm: $(RPM)

rpm_aarch64 : ARCHITECTURE = arm64
rpm_aarch64 : RPM_ARCH = aarch64
rpm_aarch64 : $(RPM)

deb: $(DEB)

tar: $(TAR)

exe: $(EXE)

zip: $(ZIP)

clean:
	$(RM) \
		$(LINUX_DEPS) \
		$(DOCUMENTBUILDER) \
		deb/build \
		deb/*.buildinfo \
		deb/*.changes \
		deb/*.ddeb \
		deb/*.deb \
		$(RPM_BUILD_DIR) \
		$(TAR_BUILD_DIR) \
		$(PRODUCT_NAME_LOW)

$(PRODUCT_NAME_LOW):
	$(MKDIR) $(DOCUMENTBUILDER)
	$(CP) $(DOCUMENTBUILDER) $(SRC)

# 	echo "Done" > $@

%/bin/$(PACKAGE_NAME) : %/bin/documentbuilder.sh.m4
	m4 $(M4_PARAMS)	$< > $@
	chmod +x $@

$(RPM): $(RPM_DEPS) $(LINUX_DEPS) $(PRODUCT_NAME_LOW)
	$(CD) rpm && rpmbuild -bb \
	--define '_topdir $(RPM_BUILD_DIR)' \
	--define '_package_name $(PACKAGE_NAME)' \
	--define '_product_version $(PRODUCT_VERSION)' \
	--define '_build_number $(BUILD_NUMBER)$(RPM_RELEASE:%=.%)' \
	--define '_publisher_name $(PUBLISHER_NAME)' \
	--define '_publisher_url $(PUBLISHER_URL)' \
	--define '_support_mail $(SUPPORT_MAIL)' \
	--define '_db_prefix $(DB_PREFIX)' \
	--define '_binary_payload w7.xzdio' \
	--target $(RPM_ARCH) \
	$(PACKAGE_NAME).spec

deb/build/debian/% : deb/template/%
	mkdir -pv $(@D) && cp -fv $< $@

deb/build/debian/% : deb/template/%.m4
	mkdir -pv $(@D) && m4 $(M4_PARAMS) $< > $@

deb/build/debian/$(PACKAGE_NAME).% : deb/template/package.%.m4
	mkdir -pv $(@D) && m4 $(M4_PARAMS) $< > $@

$(DEB): $(DEB_DEPS) $(LINUX_DEPS) $(PRODUCT_NAME_LOW)
	cd deb/build && dpkg-buildpackage -b -uc -us -a$(DEB_ARCH)

$(TAR): $(PRODUCT_NAME_LOW)
	$(MKDIR) $(dir $@) $(TAR_BUILD_DIR)/documentbuilder
	$(CP) $(TAR_BUILD_DIR)/documentbuilder $(DOCUMENTBUILDER)/*
	tar -czf $@ --owner=root --group=root -C $(TAR_BUILD_DIR) documentbuilder

% : %.m4
	m4 $(M4_PARAMS)	$< > $@

rpm/$(PACKAGE_NAME).spec : rpm/package.spec
	cp -f $< $@

ifeq ($(PLATFORM),linux)
PACKAGES += deb
PACKAGES += rpm
# PACKAGES += tar
endif

packages: $(PACKAGES)
