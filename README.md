# lamp
linux apache mysql php server

### 注意
* php.ini配置中opcache.protect_memory=0，如果设置为1会导航段错误，原因：这个参数是非线程安全的开关
* php-8.0.x的编译：LAMP=lamp8 PHP_VER=8.0.3 ./lamp-setup.sh

