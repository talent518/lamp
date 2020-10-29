#!/bin/bash -l

set -e

APR_VER=1.7.0
APR_ICONV_VER=1.2.2
APR_UTIL_VER=1.6.1
HTTPD_VER=2.4.46
PHP_VER=7.4.11
MY_VER=10.5.6

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

#############################################
# php
#############################################

if test ! -f /opt/lamp/modules/libphp7.so; then
	test ! -d /tmp/php-$PHP_VER && tar -xvf php-$PHP_VER.tar.bz2 -C /tmp

	pushd /tmp/php-$PHP_VER
	test ! -f Makefile && EXTENSION_DIR=/opt/lamp/lib/extensions ./configure CFLAGS=-O2 CXXFLAGS=-O2 --prefix=/opt/lamp --with-config-file-path=/opt/lamp/etc --with-config-file-scan-dir=/opt/lamp/etc/php.d --with-apxs2=/opt/lamp/bin/apxs --enable-inline-optimization --enable-maintainer-zts --with-tsrm-pthreads --enable-phpdbg --with-openssl --with-kerberos --with-system-ciphers --with-zlib --enable-bcmath --with-bz2 --enable-calendar --with-curl --enable-dba=shared --with-enchant --enable-exif --with-ffi --enable-ftp --enable-gd --with-external-gd --with-webp --with-jpeg --with-xpm --with-freetype --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --with-imap --with-kerberos --with-imap-ssl --enable-intl --with-ldap --with-ldap-sasl --enable-mbstring --with-mysqli --enable-pcntl --with-pdo-mysql --with-pspell --with-libedit --with-readline --enable-shmop --with-snmp --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-tidy --with-expat --with-xmlrpc --with-xsl --enable-zend-test=shared --with-zip --enable-mysqlnd
	make -j4
	make install
	test ! -d /opt/lamp/etc && mkdir /opt/lamp/etc
	\cp php.ini-* /opt/lamp/etc/
	test ! -f /opt/lamp/etc/php.ini && \cp php.ini-development /opt/lamp/etc/php.ini
	popd
fi

#############################################
# mariadb
#############################################

if test ! -f /opt/lamp/bin/mysqld; then
	test ! -d /tmp/mariadb-$MY_VER && tar -xvf mariadb-$MY_VER.tar.gz -C /tmp

	pushd /tmp/mariadb-$MY_VER
	test ! -d build && mkdir build
	pushd build
	test ! -f Makefile && cmake .. -DCMAKE_INSTALL_PREFIX=/opt/lamp -DMYSQL_DATADIR=/opt/lamp/var/mysql -DSYSCONFDIR=/opt/lamp/etc -DWITHOUT_TOKUDB=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STPRAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWIYH_READLINE=1 -DWIYH_SSL=system -DVITH_ZLIB=system -DWITH_LOBWRAP=0 -DMYSQL_UNIX_ADDR=/opt/lamp/var/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
	make -j4
	make install
	popd
	popd
fi

