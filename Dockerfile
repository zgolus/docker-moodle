# Docker-Moodle
# Dockerfile for moodle instance. more dockerish version of https://github.com/sergiogomez/docker-moodle
# Forked from Jon Auer's docker version. https://github.com/jda/docker-moodle
FROM ubuntu:16.04
MAINTAINER Jonathan Hardison <jmh@jonathanhardison.com>

VOLUME ["/var/moodledata"]
EXPOSE 80 443 2222

# Keep upstart from complaining
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Database info and other connection information derrived from env variables. See readme.
# Set ENV Variables externally Moodle_URL should be overridden.
ENV MOODLE_URL http://127.0.0.1
ENV SSH_PASSWD "root:Docker!"

RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php \
		php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl3 \
		libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring php-zip php-soap cron php7.0-ldap \
		openssh-server vim && \
	cd /tmp && \
	git clone -b MOODLE_34_STABLE git://git.moodle.org/moodle.git --depth=1 && \
	mv /tmp/moodle/* /var/www/html/ && \
	rm /var/www/html/index.html && \
	chown -R www-data:www-data /var/www/html


RUN echo "$SSH_PASSWD" | chpasswd

COPY ./foreground.sh /etc/apache2/foreground.sh
COPY moodle-config.php /var/www/html/config.php
COPY init_container.sh /bin/
COPY sshd_config /etc/ssh/

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
