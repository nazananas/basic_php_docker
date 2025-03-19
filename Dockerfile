# Используем базовый образ Amazon Linux
FROM amazonlinux:latest

# Обновляем систему и устанавливаем необходимые пакеты
RUN yum -y update && \
    yum -y install httpd php php-fpm procps && \
    yum clean all

# Создаем директорию для Unix-сокета PHP-FPM
RUN mkdir -p /run/php-fpm && \
    chown apache:apache /run/php-fpm

# Настраиваем PHP-FPM для использования Unix-сокета
RUN sed -i 's/^listen = .*/listen = \/run\/php-fpm\/www.sock/' /etc/php-fpm.d/www.conf && \
    sed -i 's/^;listen.owner = .*/listen.owner = apache/' /etc/php-fpm.d/www.conf && \
    sed -i 's/^;listen.group = .*/listen.group = apache/' /etc/php-fpm.d/www.conf && \
    sed -i 's/^;listen.mode = .*/listen.mode = 0660/' /etc/php-fpm.d/www.conf

# Настраиваем Apache для работы с Unix-сокетом PHP-FPM
RUN echo "ProxyPassMatch ^/(.*\.php)$ unix:/run/php-fpm/www.sock|fcgi://127.0.0.1:9000/var/www/html/\$1" >> /etc/httpd/conf/httpd.conf

# Копируем index.php в директорию веб-сервера
COPY ./index.php /var/www/html/index.php

# Устанавливаем права на файл index.php
RUN chown apache:apache /var/www/html/index.php && \
    chmod 644 /var/www/html/index.php

# Скрипт для запуска PHP-FPM и Apache
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Открываем порт 80
EXPOSE 80

# Запускаем скрипт start.sh
CMD ["/start.sh"]
