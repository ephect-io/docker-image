# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Build the image from the current README directory which fully qualified name is epehct/dev-image-php:version-arch.

Example:

```bash
docker build . -t epehct/dev-image-php:8.4.3-arm64
```
All possible versions values are:
- 8.4.3
- 8.3.16
- 8.2.27
- 8.1.9

Available architectures are amd64 (x86 standard PC) and arm64 (Aplle silicon, etc.). However, amd64 is the default value and doesn't need to be mentioned.
 
## Push image to DockerHub repo

Be sure to use the same fully qualified tag name: 

```bash
docker push ephect/dev-image-php:8.4.3-arm64
```
