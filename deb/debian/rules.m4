#!/usr/bin/make -f
# -*- makefile -*-

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1

%:
	dh $@

override_dh_shlibdeps:
	dh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info -l$$(pwd)/debian/M4_PACKAGE_NAME/opt/M4_DB_PREFIX:$$(pwd)/debian/M4_PACKAGE_NAME/opt/M4_DB_PREFIX/HtmlFileInternal

override_dh_builddeb:
	dh_builddeb --destdir=.
