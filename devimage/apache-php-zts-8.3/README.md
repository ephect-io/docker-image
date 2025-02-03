# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Build the image from the current README directory

```bash
docker build . -t epehct/dev-images-php:8.3.16
```

## Push image to DockerHub repo

Push by

```bash
docker push ephect/dev-images-php:8.3.16
```
