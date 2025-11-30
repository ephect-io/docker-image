# Devcontainer for PHP Development

This directory contains the configuration files for setting up a development container for PHP projects using Docker and Visual Studio Code's Remote - Containers extension.

## 📋 Prerequisite

- Docker
- Visual Studio Code
- Remote - Containers extension for Visual Studio Code

## 🚀 Getting Started

1. **Set Up the Repository:**

    Copy all stuff in `devcontainer/(apache|fpm)/repo-root` directory to your project root and customize as needed by replacing `myapp` with your project name.

2. **Open in VS Code:**

   ```bash
   code .
   ```

3. **Reopen in Container:**
    - Press `F1` and select `Remote-Containers: Reopen in Container`.
    - VS Code will build the Docker image and start the container.

4. **Access Your Application:** 
    Open your browser and navigate to `http://myapp.docker.internal:8888` to see your PHP application running inside the container.

## ⚙️ Configuration

- You can modify the `Dockerfile` and `compose.yaml` files to customize the PHP version, installed extensions, and other settings.

- The `xdebug.ini` file configures Xdebug settings. Adjust the configuration as needed for your debugging setup.

## 🐞 Debugging with Xdebug

1. **Set Up Xdebug:**
   - Ensure Xdebug is installed and enabled in your PHP environment.
   - Update the `xdebug.ini` file with the appropriate settings for your environment.

2. **Configure VS Code:**
   - Install the PHP Debug extension for Visual Studio Code.
   - Create a `launch.json` file in the `.vscode` directory of your project with the following configuration:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9000
        }
    ]
}
```

3. **Start Debugging:**

   - Set breakpoints in your PHP code.
   - Start the debugging session in VS Code by selecting the "Listen for Xdebug" configuration.
   - Trigger the PHP script in your browser to hit the breakpoints.

## 📚 Additional Resources

- [Xdebug Documentation](https://xdebug.org/docs)
- [PHP Debug Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug)
- [Remote - Containers Extension](https://code.visualstudio.com/docs/remote/containers) 

