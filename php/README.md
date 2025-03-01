# Docker procedure

## Build new image

Login to DockerHub

```bash
docker login
```

Using the make command like this: 

```
make build package=<package> version=<version>
```

Possible package are:
 - apahce, fpm, zts.

Possible argument is:
 - version: any PHP version available in DockerHub at https://hub.docker.com/_/php/tags or nothing, default version is latest.

Example:

```
  make build package=apache version=8.2.27
```
 
This will build the PHP image in version 8.2.27 with a ready to use Apache server on port 80 for both X86_64 and ARM64 arch. 

## Other commands

```
make push package=<package> version=<version>
make help
```
