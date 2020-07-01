FROM debian:buster as intermediate
#Label the image for cleaning after build process
LABEL stage=intermediate
ENV LIMESURVEY_VERSION="4.2.8+200608"
ENV DOCKER_REPO="https://github.com/LimeSurvey/LimeSurvey.git"

# optional usage of local apt-cacher proxy
#RUN  echo 'Acquire::http { Proxy "http://172.32.99.12:3142"; };' >> /etc/apt/apt.conf.d/01proxy

# Set repositories
RUN \
  echo "deb http://ftp.de.debian.org/debian/ buster main non-free contrib" > /etc/apt/sources.list && \
  echo "deb-src http://ftp.de.debian.org/debian/ buster main non-free contrib" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ buster/updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ buster/updates main contrib non-free" >> /etc/apt/sources.list && \
  apt-get -qq update && apt-get -qqy upgrade && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Install some basic tools needed for deployment
RUN apt-get -qq update && \
  apt-get -yqq install git \
  && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 -b ${LIMESURVEY_VERSION} ${DOCKER_REPO}

#RUN cd LimeSurvey && git fetch origin ${LIMESURVEY_VERSION} && git checkout ${LIMESURVEY_VERSION}

####

FROM mattrayner/lamp:latest-1804
COPY --from=intermediate /LimeSurvey /app

# Set repositories
RUN apt-get -qq update && apt-get -qqy upgrade && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Install some basic tools needed for deployment
#RUN apt-get -qq update && \
  #apt-get -yqq install \
  #apt-utils \
  #build-essential \
  #debconf-utils \
  #debconf \
  #default-mysql-client \
  #locales \
  #curl \
  #wget \
  #unzip \
  #patch \
  #rsync \
  #vim \
  #nano \
  #openssh-client \
  #git \
  #bash-completion \
  #locales \
  #libjpeg-turbo-progs libjpeg-progs \
  #pngcrush optipng \
  #&& apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

# Configure Sury sources
# @see https://www.noobunbox.net/serveur/auto-hebergement/installer-php-7-1-sous-debian-et-ubuntu
#RUN apt-get -qq update && \
  #apt-get -yqq install apt-transport-https lsb-release ca-certificates  curl && \
  #wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
  #echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
  #apt-get -qq update && apt-get -qqy upgrade && apt-get -q autoclean && rm -rf /var/lib/apt/lists/*

#RUN apt-get update -q -y && \
	#apt-get upgrade -q -y && \
	#apt-get install -q -y php7.4 && \
	#apt-get install -q -y \
        #apache2 \
          #curl  \
          #sendmail \
          #php7.4-gd \
          #php7.4-ldap \
          #php7.4-imap \
          #php7.4-pgsql \
          #php7.4-curl && \
	#apt-get clean && \
	#phpenmod imap

#RUN chown www-data:www-data /var/lib/php7

ADD apache_default /etc/apache2/sites-available/000-default.conf
ADD start.sh /
ADD run.sh /

RUN chmod +x /start.sh && \
    chmod +x /run.sh

RUN apt-get update -q -y && \
	apt-get upgrade -q -y

RUN rm -rf /app/.git && \
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
