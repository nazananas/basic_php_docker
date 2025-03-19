#!/bin/bash
# Запуск PHP-FPM в фоновом режиме
/usr/sbin/php-fpm -D

# Запуск Apache в foreground
/usr/sbin/httpd -D FOREGROUND
