#!/usr/bin/make -f

export DH_VERBOSE=1

%:
	dh $@

override_dh_shlibdeps:
	dh_shlibdeps --no-act
