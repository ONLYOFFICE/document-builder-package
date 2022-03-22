Source: M4_PACKAGE_NAME
Section: utils
Priority: optional
Maintainer: M4_PUBLISHER_NAME <M4_SUPPORT_MAIL>
Build-Depends: debhelper (>= 8.0.0)

Package: M4_PACKAGE_NAME
Architecture: M4_DEB_ARCH
Depends: libxml2,
  libcurl3 | libcurl4,
  libcurl3-gnutls,
  libc6,
  fonts-opensymbol,
  fonts-dejavu | ttf-dejavu 
Recommends: fonts-liberation,
  ttf-mscorefonts-installer,
  fonts-crosextra-carlito
Description: tool to create documents in office file formats including Office Open XML formats:
 .docx, .xlsx, .pptx.
