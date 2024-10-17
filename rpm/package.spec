Summary: Online viewers and editors for text, spreadsheet and presentation files
Name: %{_package_name}
Version: %{_product_version}
Release: %{_build_number}
License: Commercial
Group: Applications/File
URL: %{_publisher_url}
Vendor: %{_publisher_name}
Packager: %{_publisher_name} <%{_support_mail}>
Requires: glibc, libcurl, libxml2, dejavu-sans-fonts, dejavu-sans-mono-fonts, dejavu-serif-fonts, libreoffice-opensymbol-fonts
AutoReq: no
AutoProv: no

%description
tool to create documents in office file formats including Office Open XML formats:
 .docx, .xlsx, .pptx.

%prep
rm -rf "%{buildroot}"

%build

%install
BUILD_DIR=../../../build
BIN_DIR=%{buildroot}%{_bindir}

mkdir -p %{buildroot}
cp -rt %{buildroot}/ $BUILD_DIR/*
ln -srf $BIN_DIR/%{_package_name} $BIN_DIR/documentbuilder

%clean
rm -rf "%{buildroot}"

%files
%attr(-, root, root) /opt/%{_db_prefix}/*
%attr(-, root, root) /usr/bin/*

%changelog
* Tue Jul 26 2016 $PUBLISHER_NAME <$SUPPORT_MAIL>
- Initial release.
