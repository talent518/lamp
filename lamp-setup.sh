#!/bin/bash -l

set -e

if test -z "$LAMP"; then
	LAMP=lamp
fi

APR_VER=1.7.0
APR_ICONV_VER=1.2.2
APR_UTIL_VER=1.6.1
HTTPD_VER=2.4.46
if test -z "$PHP_VER"; then
PHP_VER=7.4.11
fi
MY_VER=10.5.6

#############################################
# apr
#############################################

if test ! -f /opt/$LAMP/lib/libapr-1.so; then
	test ! -d /tmp/apr-$APR_VER && tar -xvf apr-$APR_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-$APR_VER
	test ! -f Makefile && ./configure --prefix=/opt/$LAMP --enable-threads --enable-posix-shm --with-sendfile
	make -j4
	make install
	popd
fi

#############################################
# apr-iconv
#############################################

if test ! -f /opt/$LAMP/lib/libapriconv-1.so; then
	test ! -d /tmp/apr-iconv-$APR_ICONV_VER && tar -xvf apr-iconv-$APR_ICONV_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-iconv-$APR_ICONV_VER
	test ! -f Makefile && ./configure --prefix=/opt/$LAMP --with-apr=/opt/$LAMP
	make -j4
	make install
	popd
fi

#############################################
# apr-util
#############################################

if test ! -f /opt/$LAMP/lib/libaprutil-1.so; then
	test ! -d /tmp/apr-util-$APR_UTIL_VER && tar -xvf apr-util-$APR_UTIL_VER.tar.bz2 -C /tmp

	pushd /tmp/apr-util-$APR_UTIL_VER
	test ! -f Makefile && ./configure --prefix=/opt/$LAMP --with-apr=/opt/$LAMP
	make -j4
	make install
	popd
fi

#############################################
# httpd
#############################################

if test ! -f /opt/$LAMP/bin/httpd; then
	test ! -d /tmp/httpd-$HTTPD_VER && tar -xvf httpd-$HTTPD_VER.tar.bz2 -C /tmp

	pushd /tmp/httpd-$HTTPD_VER
	test ! -f Makefile && ./configure --prefix=/opt/$LAMP --with-apr=/opt/$LAMP --with-apr-util=/opt/$LAMP --enable-load-all-modules --enable-mpms-shared=all
	make -j4
	make install
	popd
fi

#############################################
# php
#############################################

if test "${PHP_VER:0:3}" = "8.0"; then
	PHP_SO=php
else
	PHP_SO=php7
fi

if test ! -f /opt/$LAMP/modules/lib$PHP_SO.so; then
	test ! -d /tmp/php-$PHP_VER && tar -xvf php-$PHP_VER.tar.bz2 -C /tmp

	if test "${PHP_VER:0:3}" = "8.0"; then
		PHP_CFG="--enable-zts --enable-phpdbg --with-openssl --with-kerberos --with-system-ciphers --with-zlib --enable-bcmath --with-bz2 --enable-calendar --with-curl --enable-dba=shared --with-enchant --enable-exif --with-ffi --enable-ftp --enable-gd --with-external-gd --with-webp --with-jpeg --with-xpm --with-freetype --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --with-imap --with-kerberos --with-imap-ssl --enable-intl --with-ldap --with-ldap-sasl --enable-mbstring --with-mysqli --enable-pcntl --with-pdo-mysql --with-pspell --with-libedit --with-readline --enable-shmop --with-snmp --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-tidy --with-expat --with-xsl --enable-zend-test=shared --with-zip --enable-mysqlnd"
	else
		PHP_CFG="--enable-inline-optimization --enable-maintainer-zts --with-tsrm-pthreads --enable-phpdbg --with-openssl --with-kerberos --with-system-ciphers --with-zlib --enable-bcmath --with-bz2 --enable-calendar --with-curl --enable-dba=shared --with-enchant --enable-exif --with-ffi --enable-ftp --enable-gd --with-external-gd --with-webp --with-jpeg --with-xpm --with-freetype --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --with-imap --with-kerberos --with-imap-ssl --enable-intl --with-ldap --with-ldap-sasl --enable-mbstring --with-mysqli --enable-pcntl --with-pdo-mysql --with-pspell --with-libedit --with-readline --enable-shmop --with-snmp --enable-soap --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --with-tidy --with-expat --with-xmlrpc --with-xsl --enable-zend-test=shared --with-zip --enable-mysqlnd"
	fi

	pushd /tmp/php-$PHP_VER
	test ! -f Makefile && EXTENSION_DIR=/opt/$LAMP/lib/extensions ./configure CFLAGS=-O2 CXXFLAGS=-O2 --prefix=/opt/$LAMP --with-config-file-path=/opt/$LAMP/etc --with-config-file-scan-dir=/opt/$LAMP/etc/php.d --with-apxs2=/opt/$LAMP/bin/apxs $PHP_CFG
	make -j4
	make install
	test ! -d /opt/$LAMP/etc && mkdir /opt/$LAMP/etc
	\cp php.ini-* /opt/$LAMP/etc/
	test ! -f /opt/$LAMP/etc/php.ini && \cp php.ini-development /opt/$LAMP/etc/php.ini
	popd
fi

#############################################
# mariadb
#############################################

if test ! -f /opt/$LAMP/bin/mysqld; then
	test ! -d /tmp/mariadb-$MY_VER && tar -xvf mariadb-$MY_VER.tar.gz -C /tmp

	pushd /tmp/mariadb-$MY_VER
	test ! -d build && mkdir build
	pushd build
	test ! -f Makefile && cmake .. -DCMAKE_INSTALL_PREFIX=/opt/$LAMP -DMYSQL_DATADIR=/opt/$LAMP/var/mysql -DSYSCONFDIR=/opt/$LAMP/etc -DWITHOUT_TOKUDB=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STPRAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWIYH_READLINE=1 -DWIYH_SSL=system -DVITH_ZLIB=system -DWITH_LOBWRAP=0 -DMYSQL_UNIX_ADDR=/opt/$LAMP/var/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
	make -j4
	make install
	popd
	popd
fi

