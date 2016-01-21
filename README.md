LimeSurvey
==========

LimeSurvey - the most popular
Free Open Source Software survey tool on the web.

https://www.limesurvey.org/en/

This docker image easies limesurvey installation. It includes a MySQL database as well a web server.

## Usage
To run limesurvey in 80 port just:

    docker pull crramirez/limesurvey:latest
    docker run -d --name limesurvey -p 80:80 crramirez/limesurvey:latest

