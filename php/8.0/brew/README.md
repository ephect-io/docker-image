# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Build the image from the current README directory

```bash
docker build . -t ephect/phpbrew-zts:8.0.15
```

## Push image to DockerHub repo

Push by 

```bash
docker push ephect/phpbrew-zts:8.0.15
```
