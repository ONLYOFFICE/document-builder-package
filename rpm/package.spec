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

DOCUMENTBUILDER_BIN=%{_builddir}/../../../common/documentbuilder/bin
DOCUMENTBUILDER_HOME=%{_builddir}/../../../common/documentbuilder/home

BIN_DIR=%{buildroot}%{_bindir}
HOME_DIR=%{buildroot}/opt/%{_db_prefix}

#install documentbuilder files
mkdir -p "$HOME_DIR/"
cp -r $DOCUMENTBUILDER_HOME/* "$HOME_DIR/"

#install documentbuilder bin
mkdir -p "$BIN_DIR/"
cp -r $DOCUMENTBUILDER_BIN/%{_package_name} "$BIN_DIR/"
ln -srf $BIN_DIR/%{_package_name} $BIN_DIR/documentbuilder

%clean
rm -rf "%{buildroot}"

%files
%attr(-, root, root) /opt/%{_db_prefix}/*
%attr(-, root, root) /usr/bin/*

%pre

%post

%preun

%postun

%changelog
* Tue Jul 26 2016 $PUBLISHER_NAME <$SUPPORT_MAIL>
- Initial release.
