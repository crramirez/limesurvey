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

1. Go to a browser and type http://localhost
2. Click Next until you reach the *Database configuration* screen
3. Then enter the following in the field:
  - **Database type** *MySQL*
  - **Database location** *localhost*
  - **Database user** root*
  - **Database password**
  - **Database name** *limesurvey* #Or whatever you like
  - **Table prefix** *lime_* #Or whatever you like
