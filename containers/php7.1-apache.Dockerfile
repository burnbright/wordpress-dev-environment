FROM php:7.1-apache-jessie

RUN apt-get update -y && apt-get install -y \
		ssmtp \
		gettext-base \
		curl \
		git-core \
		gzip \
		libcurl4-openssl-dev \
		libgd-dev \
		libjpeg-dev \
		libpng-dev \
		libldap2-dev \
		libmcrypt-dev \
		libtidy-dev \
		libxslt-dev \
		zlib1g-dev \
		libicu-dev \
		libzip-dev \
		g++ \
		openssh-client \
	--no-install-recommends && \
	rm -r /var/lib/apt/lists/*

# Install PHP Extensions
RUN docker-php-ext-configure intl && \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
	docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-gif-dir=/usr/include/ --with-png-dir=/usr/include/ && \
	docker-php-ext-install -j$(nproc) \
		bcmath \
		intl \
		gd \
		ldap \
		mysqli \
		pdo \
		pdo_mysql \
		soap \
		xsl \
		zip \
		mcrypt

COPY ./php.ini /usr/local/etc/php/

# PHP mail settings
ENV SSMTP_HOST=mail
ENV SSMTP_PORT=25
ENV SSMTP_FROM_HOSTNAME=
ENV SSMTP_USE_TLS=No
ENV SSMTP_USE_STARLTLS=No
ENV SSMTP_AUTH_METHOD=
ENV SSMTP_AUTH_USER=
ENV SSMTP_AUTH_PASSWORD=
COPY ./ssmtp.conf.tpl /ssmtp.conf.tpl
RUN echo 'sendmail_path=/usr/sbin/ssmtp -oi -t' >> /usr/local/etc/php/conf.d/mail.ini

# Install composer
COPY ./install-composer.sh /tmp/install-composer.sh
RUN apt-get update -yq && apt-get install -yqq \
		git zip ssh
RUN chmod +x /tmp/install-composer.sh && /tmp/install-composer.sh

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
	echo "date.timezone = Pacific/Auckland" > /usr/local/etc/php/conf.d/timezone.ini && \
	a2enmod rewrite expires remoteip cgid && \
	usermod -u 1000 www-data && \
	usermod -G staff www-data

# Install PECL Extensions
RUN pecl install zip

# XDebug
RUN pecl install xdebug
RUN XDEBUG_INI=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
	docker-php-ext-enable xdebug && \
	sed -i '1 a xdebug.remote_autostart=1' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_mode=req' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_handler=dbgp' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_host=127.0.0.1' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_connect_back=0' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_port=9000' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_enable=1' $XDEBUG_INI && \
	sed -i '1 a xdebug.remote_log=/var/log/xdebug.log' $XDEBUG_INI

RUN touch /var/log/xdebug.log && \
	(. "$APACHE_ENVVARS" && \
		chown -R "$APACHE_RUN_USER:$APACHE_RUN_GROUP" /var/log/xdebug.log)

COPY ./docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
RUN chmod u+x /usr/local/bin/docker-php-entrypoint
ENTRYPOINT ["docker-php-entrypoint"]

WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]