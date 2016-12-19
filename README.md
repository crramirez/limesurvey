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

You are ready to go.

### Environment variables

To run limesurvey in a different http location set the `HTTP_LOCATION` environment variable.

    docker run -d --name limesurvey -p 80:80 -e HTTP_LOCATION="surveys" crramirez/limesurvey:latest

Limesurvey will then be available via http://localhost/surveys.

## Database in volumes

If you want to preserve data in the event of a container deletion, or version upgrade, you can assign the MySQL data into a named volume:
    
    docker volume create --name mysql
    docker run -d --name limesurvey -v mysql:/var/lib/mysql -p 80:80 crramirez/limesurvey:latest
    

If you delete the container simply run again the above command. The installation page will appear again. Don't worry just put the same parameters as before and limesurvey will recognize the database.


## Upload folder

If you want to preserve the uploaded files in the event of a container deletion, or version upgrade, you can assign the upload folder into a named volume:

    docker volume create --name upload
    docker run -d --name limesurvey -v upload:/app/upload -v mysql:/var/lib/mysql -p 80:80 crramirez/limesurvey:latest


If you delete the container simply run again the above command. The installation page will appear again. Don't worry just put the same parameters as before and limesurvey will recognize the database and the uploaded files including images.

## Using Docker Compose

You can use docker compose to automate the above command if you create a file called *docker-compose.yml* and put in there the following:

    version: '2'
    services:
      limesurvey:
        ports:
          - "80:80"
        volumes:
          - mysql:/var/lib/mysql
          - upload:/app/upload
        image:
          crramirez/limesurvey:latest
    volumes:
      mysql:
      upload:



And run:

    docker-compose up -d
