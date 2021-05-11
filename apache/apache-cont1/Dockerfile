FROM php:7.4-apache


RUN apt-get update && apt-get upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends nano git curl apt-utils \
    libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libonig-dev \
    libmagickwand-dev libzip-dev sendmail sendmail-bin cron git nano sudo

RUN docker-php-ext-install -j$(nproc) exif && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install -j$(nproc) iconv && \
    docker-php-ext-install -j$(nproc) mbstring && \
    docker-php-ext-install -j$(nproc) opcache && \
    docker-php-ext-install -j$(nproc) pdo && \
    docker-php-ext-install -j$(nproc) pdo_mysql && \
    docker-php-ext-install -j$(nproc) zip && \
    pecl install mcrypt-1.0.3 && \
    docker-php-ext-enable mcrypt && \
    pecl install imagick-3.4.4 && \
    docker-php-ext-enable imagick && \
    rm -rf /var/lib/apt/lists/* 


COPY php.ini /var/www/php.ini
COPY una.conf /etc/apache2/sites-available/una.conf
COPY entrypoint.sh /bin/entrypoint.sh
COPY entrypoint-var.env /var/entrypoint/entrypoint-var.env

RUN groupadd -r -g 2483 www-una
RUN useradd -r -m -s /bin/bash -u 2483 --gid 2483 -G www-una www-una
RUN a2enmod headers rewrite expires ssl && \
    a2ensite una.conf
RUN chmod +x /bin/entrypoint.sh

ENTRYPOINT [ "/bin/entrypoint.sh" ]
CMD ["apache2-foreground"]