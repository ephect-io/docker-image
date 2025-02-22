# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Build the image from the current README directory

```bash
docker build . -t ephect/php-fpm-zts:8.1.9
```

## Push image to DockerHub repo

Push by 

```bash
docker push ephect/php-fpm-zts:8.1.9
```
