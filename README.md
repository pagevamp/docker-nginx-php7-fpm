# Nginx php7-fpm Docker

This is a Dockerfile to build a container image consisting of nginx, php-fpm and composer.

### Docker hub repository
The Docker hub build can be found here: [https://hub.docker.com/r/pagevamp/nginx-php7-fpm/](https://hub.docker.com/r/pagevamp/nginx-php7-fpm/)

## Versions
- Nginx Mainline Version: **1.12.1**
- PHP: **7.***
- Ubuntu Trusty: **16.04**

## Branch Naming Convention
The branch name will be as the php version. For eg. **7.0** branch will be with php v. 7.0

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/pagevamp/docker-nginx-php7-fpm.git
docker build -t pagevamp/nginx-php7-fpm:latest .
```

## Pulling from Docker Hub
Pull the image from docker hub rather than downloading the git repo. This prevents you having to build the image on host:
```
docker pull pagevamp/nginx-php7-fpm:latest
```

## Running
To simply run the container:
```
docker run --name app -p 8080:80 pagevamp/nginx-php7-fpm
```

You can then browse to ```http://<HOST>:8080``` to view the default install files.

### Volumes
If you want to link to your web site directory on the docker host to the container run:
```
docker run --name mypvapp -p 8080:80 -v /your_code_directory:/var/www -d pagevamp/nginx-php7-fpm
```