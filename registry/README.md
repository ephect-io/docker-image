# Rocker - Local Docker Registry Manager

This script helps you manage a local Docker registry for development purposes.

## Prerequisites

- Docker must be installed and running
- Internet connection to pull the registry image (first time only)

## Configuration

You can create a `~/.rorc` file to set custom values:

```bash
export ROCKER_PORT=5000
export ROCKER_HOST=localhost
```

## Commands

### Create Registry
```bash
./rocker create
```
Creates a new local Docker registry container running on `localhost:5000` (or your configured host/port).

### Start Registry
```bash
./rocker start
```
Starts an existing registry container.

### Stop Registry
```bash
./rocker stop
```
Stops the running registry container.

### Destroy Registry
```bash
./rocker destroy
```
Removes the registry container completely (including any stored images).

## Using Your Local Registry

Once your registry is running, you can:

1. **Tag an image for your local registry:**
   ```bash
   docker tag myimage:latest localhost:5000/myimage:latest
   ```

2. **Push to your local registry:**
   ```bash
   docker push localhost:5000/myimage:latest
   ```

3. **Pull from your local registry:**
   ```bash
   docker pull localhost:5000/myimage:latest
   ```

## Troubleshooting

### Docker Hub Connection Issues
If you're experiencing connectivity issues with Docker Hub:

1. **Check Docker daemon:**
   ```bash
   docker info
   ```

2. **Try pulling the registry image manually:**
   ```bash
   docker pull registry:latest
   ```

3. **Alternative: Use a pre-downloaded registry image**
   If you have the registry image available locally or can download it from another source.

### Registry Already Exists
If you get an error that the registry already exists:
- Use `./rocker start` to start an existing registry
- Use `./rocker destroy` to remove it first, then `./rocker create`

### Port Already in Use
If port 5000 is already in use:
- Set a different port in your `~/.rorc` file
- Or stop the service using port 5000

## Security Note

This local registry is **NOT secure** and should only be used for development purposes on your local machine or trusted networks.
