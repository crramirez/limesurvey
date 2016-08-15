FROM tutum/lamp

RUN apt-get update ; \
	apt-get upgrade -q -y ;\
	apt-get install -q -y curl php5-gd php5-ldap php5-imap unzip wget; apt-get clean ; \
	php5enmod imap

RUN rm -rf /app 

RUN wget https://github.com/LimeSurvey/LimeSurvey/archive/master.zip; \
    unzip master.zip; \
    mv LimeSurvey-master /app

RUN mkdir -p /uploadstruct; \
	chown -R www-data:www-data /app

RUN cp -r /app/upload/* /uploadstruct ; \
	chown -R www-data:www-data /uploadstruct

RUN chown www-data:www-data /var/lib/php5

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD start.sh /

RUN chmod +x /start.sh

VOLUME /app/upload

EXPOSE 80 3306
CMD ["/start.sh"]

