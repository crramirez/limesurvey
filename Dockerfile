
FROM tutum/lamp

RUN apt-get update -q -y && \
	apt-get upgrade -q -y && \
	apt-get install -q -y curl php5-gd php5-ldap php5-imap sendmail php5-pgsql php5-curl && \
	apt-get clean && \
	php5enmod imap

RUN chown www-data:www-data /var/lib/php5

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD start.sh /
ADD run.sh /

RUN chmod +x /start.sh && \
    chmod +x /run.sh

ENV LIMESURVEY_VERSION="3.17.0+190402"

RUN apt-get update -q -y && \
	apt-get upgrade -q -y
	
RUN rm -rf /app && \
    git clone https://github.com/LimeSurvey/LimeSurvey.git && \
    cd LimeSurvey && git checkout ${LIMESURVEY_VERSION} && cd .. && \
    rm -rf /LimeSurvey/.git && \
    mv LimeSurvey app && \
    mkdir -p /app/upload/surveys && \
	mkdir -p /uploadstruct && \
	chown -R www-data:www-data /app && \
    cp -a /app/upload/* /uploadstruct

SHELL ["/bin/bash", "--login", "-c"]

RUN versions=(${LIMESURVEY_VERSION//+/ }) && \
    version=${versions[1]} && \
    sed -r -i "s/(config\['buildnumber'\] = ')(.*)('\;$)/\1${version}\3/g" /app/application/config/version.php

VOLUME /app/upload
VOLUME /app/plugins

EXPOSE 80 3306
CMD ["/start.sh"]
