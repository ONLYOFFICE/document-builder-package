Summary: Online viewers and editors for text, spreadsheet and presentation files
Name: onlyoffice-documentbuilder
Version: {{PRODUCT_VERSION}}
Release: {{BUILD_NUMBER}}
License: Commercial
Group: Applications/File
URL: http://onlyoffice.com/
Vendor: ONLYOFFICE (document builder)
Packager: ONLYOFFICE (document builder) <support@onlyoffice.com>
Requires: glibc, libcurl, libxml2
BuildArch: x86_64
AutoReq: no
AutoProv: no

%description
tool to create documents in office file formats including Office Open XML formats:
 .docx, .xlsx, .pptx.

%prep
rm -rf "$RPM_BUILD_ROOT"

%build

%install

DOCUMENTSERVER_BIN=../../../common/documentbuilder/bin
DOCUMENTSERVER_HOME=../../../common/documentbuilder/home

#install documentbuilder files
mkdir -p "$RPM_BUILD_ROOT/opt/onlyoffice/documentbuilder/"
cp -r $DOCUMENTSERVER_HOME/* "$RPM_BUILD_ROOT/opt/onlyoffice/documentbuilder/"

#install documentbuilder bin
mkdir -p "$RPM_BUILD_ROOT/usr/bin/"
cp -r $DOCUMENTSERVER_BIN/* "$RPM_BUILD_ROOT/usr/bin/"

%clean
rm -rf "$RPM_BUILD_ROOT"

%files
%attr(-, root, root) /opt/onlyoffice/documentbuilder/*
%attr(-, root, root) /usr/bin/*

%pre

%post
ln -sf /usr/lib64/libcurl.so.4 /opt/onlyoffice/documentbuilder/libcurl-gnutls.so.4

%preun
unlink /opt/onlyoffice/documentbuilder/libcurl-gnutls.so.4

%postun

%changelog
* Tue Jul 26 2016 ONLYOFFICE (document builder) <support@onlyoffice.com>
- Initial release.
