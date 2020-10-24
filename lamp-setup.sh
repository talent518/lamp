#!/bin/bash -l

set -e

APR_VER=1.7.0
APR_ICONV_VER=1.2.2
APR_UTIL_VER=1.6.1
HTTPD_VER=2.4.46

#############################################
# apr
#############################################

if test ! -f /opt/lamp/lib/libapr-1.so; then
	test ! -d /tmp/apr-$APR_VER && tar -xvf apr-$APR_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-$APR_VER
	test ! -f Makefile && ./configure --prefix=/opt/lamp --enable-threads --enable-posix-shm --with-sendfile
	make -j4
	make install
	popd
fi

#############################################
# apr-iconv
#############################################

if test ! -f /opt/lamp/lib/libapriconv-1.so; then
	test ! -d /tmp/apr-iconv-$APR_ICONV_VER && tar -xvf apr-iconv-$APR_ICONV_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-iconv-$APR_ICONV_VER
	test ! -f Makefile && ./configure --prefix=/opt/lamp --with-apr=/opt/lamp
	make -j4
	make install
	popd
fi

#############################################
# apr-util
#############################################

if test ! -f /opt/lamp/lib/libaprutil-1.so; then
	test ! -d /tmp/apr-util-$APR_UTIL_VER && tar -xvf apr-util-$APR_UTIL_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-util-$APR_UTIL_VER
	test ! -f Makefile && ./configure --prefix=/opt/lamp --with-apr=/opt/lamp
	make -j4
	make install
	popd
fi

#############################################
# httpd
#############################################

if test ! -f /opt/lamp/bin/httpd; then
	test ! -d /tmp/httpd-$HTTPD_VER && tar -xvf httpd-$HTTPD_VER.tar.bz2 -C /tmp

	pushd /tmp/httpd-$HTTPD_VER
	test ! -f Makefile && ./configure --prefix=/opt/lamp --with-apr=/opt/lamp --with-apr-util=/opt/lamp --enable-load-all-modules --enable-mpms-shared=all
	make -j4
	make install
	popd
fi


