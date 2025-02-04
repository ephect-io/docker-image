# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Build the image from the current README directory

```bash
docker build . -t ephect/dev-image-php:8.2.27
```

## Push image to DockerHub repo

Push by

```bash
docker push ephect/dev-image-php:8.2.27
```
