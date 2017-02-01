FROM php:5.6-apache

ENV DOWNLOAD_URL https://www.limesurvey.org/stable-release?download=1984:limesurvey2620%20170124targz

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libc-client-dev libfreetype6-dev libmcrypt-dev libpng12-dev libjpeg-dev libldap2-dev zlib1g-dev libkrb5-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/  --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli mysql opcache zip iconv mcrypt \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \ 
    && docker-php-ext-install ldap \ 
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \ 
    && docker-php-ext-install imap 

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME ["/var/www/html"]

RUN set -x \
	&& curl -SL "$DOWNLOAD_URL" -o /tmp/lime.tar.gz \
	&& mkdir /usr/src/limesurvey \
    && tar xf /tmp/lime.tar.gz --strip-components=1 -C /usr/src/limesurvey \ 
    && chown -R www-data:www-data /usr/src/limesurvey

#Set PHP defaults for Limesurvey (allow bigger uploads)
RUN { \
		echo 'memory_limit=256M'; \
		echo 'upload_max_filesize=128M'; \
		echo 'post_max_size=128M'; \
		echo 'max_execution_time=120'; \
        echo 'max_input_vars=10000'; \
        echo 'date.timezone=UTC'; \
	} > /usr/local/etc/php/conf.d/uploads.ini

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

# ENTRYPOINT resets CMD
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
