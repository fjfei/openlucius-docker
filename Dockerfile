# from docker run --name d7 -p 8080:80 -d drupal:7
# from docker run --name some-drupal --link some-mysql:mysql -d drupal
# docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.7
FROM drupal:7

# install the PHP extensions we need
RUN set -ex; \
	apt-get update && apt-get upgrade -y; \
	apt-get install -y --no-install-recommends \
	  git subversion openssh-client mercurial  bash patch zip unzip\
      vim nano \
      mysql-client ;\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \

#RUN docker-php-ext-install pdo_mysql

##  # see https://secure.php.net/manual/en/opcache.installation.php
##  RUN { \
##  		echo 'opcache.memory_consumption=128'; \
##  		echo 'opcache.interned_strings_buffer=8'; \
##  		echo 'opcache.max_accelerated_files=4000'; \
##  		echo 'opcache.revalidate_freq=60'; \
##  		echo 'opcache.fast_shutdown=1'; \
##  		echo 'opcache.enable_cli=1'; \
##  	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN echo "memory_limit=-1" > "/usr/local/etc/php/conf.d/memory-limit.ini" \
 && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "/usr/local/etc/php/conf.d/date_timezone.ini"
 
# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install drush 8.x. https://github.com/drush-ops/drush/releases/download/8.1.18/drush.phar
RUN curl -fSL "https://github.com/drush-ops/drush/releases/download/8.1.18/drush.phar" -o /usr/local/bin/drush ;\ 
    chmod +x /usr/local/bin/drush

WORKDIR /var/www/html

# https://www.drupal.org/project/openlucius/releases
ENV OL_VERSION 7.x-1.7
ENV OL_MD5 9086fd0851cbafce0ed3ff6d5ab3dae8

RUN curl -fSL "https://ftp.drupal.org/files/projects/openlucius-${OL_VERSION}-core.tar.gz" -o openlucius.tar.gz \
	&& echo "${OL_MD5} *openlucius.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f openlucius.tar.gz \
	&& rm openlucius.tar.gz \
	&& chown -R www-data:www-data sites modules themes
