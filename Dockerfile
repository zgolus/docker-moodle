FROM ubuntu:16.04

VOLUME ["/var/moodledata"]
EXPOSE 80 443 2222

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

ENV MOODLE_URL http://127.0.0.1
ENV SSH_PASSWD "root:Docker!"

RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php \
		php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl3 \
		libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring php-zip php-soap cron php7.0-ldap php7.0-opcache \
		openssh-server vim

RUN echo "$SSH_PASSWD" | chpasswd

COPY app /var/www/html/
RUN rm /var/www/html/index.html && \
	chown -R www-data:www-data /var/www/html

COPY ./foreground.sh /etc/apache2/foreground.sh
COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/
COPY php.ini /etc/php/7.0/apache2/

RUN chmod +x /etc/apache2/foreground.sh && \
	chmod 755 /bin/init_container.sh

#cron
COPY moodlecron /etc/cron.d/moodlecron
RUN chmod 0644 /etc/cron.d/moodlecron

# Enable SSL, moodle requires it
RUN a2enmod ssl && a2ensite default-ssl  #if using proxy dont need actually secure connection

# Cleanup, this is ran to reduce the resulting size of the image.
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /tmp/* /var/tmp/* /var/lib/cache/* /var/lib/log/*

ENTRYPOINT ["/bin/init_container.sh"]
