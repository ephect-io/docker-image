# FrankenPHP Development Image

Modern PHP application server built on top of [FrankenPHP](https://frankenphp.dev/).

## 🚀 Features

- **FrankenPHP** - Modern PHP app server with Caddy
- **HTTP/2 & HTTP/3** - Built-in support
- **PHP Workers** - Long-running PHP processes
- **Early Hints** - For improved performance
- **Xdebug** - Pre-configured for debugging
- **Composer** - PHP dependency manager
- **NVM & Node.js LTS** - For frontend tooling
- **Yarn via Corepack** - Modern package manager

## 📦 Available Extensions

- zip, pdo_mysql, pdo_pgsql, opcache, intl, gd
- xdebug (for development)

## 🏃 Quick Start

### Basic Usage

```bash
docker run -d -p 80:80 -p 443:443 \
  -v $(pwd):/app \
  localhost:5100/dev-php:franken-8.5.0
```

### With Custom Caddyfile

```bash
docker run -d -p 80:80 -p 443:443 \
  -v $(pwd):/app \
  -v $(pwd)/Caddyfile:/etc/caddy/Caddyfile \
  localhost:5100/dev-php:franken-8.5.0
```

### Development with Xdebug

```bash
docker run -d -p 80:80 -p 443:443 \
  -e XDEBUG_MODE=debug \
  -v $(pwd):/app \
  localhost:5100/dev-php:franken-8.5.0
```

## 🔧 Configuration

### Environment Variables

- `FRANKENPHP_NUM_THREADS` - Number of worker threads (default: 2)
- `XDEBUG_MODE` - Xdebug mode (default: develop,coverage,debug)

### PHP Workers

Create a `worker.php` file and configure it in your Caddyfile:

```caddyfile
{
    frankenphp {
        worker /app/worker.php 4
    }
}
```

### HTTPS with HTTP/3

FrankenPHP automatically generates self-signed certificates for development:

```bash
docker run -d -p 443:443 -p 443:443/udp \
  -v $(pwd):/app \
  localhost:5100/dev-php:franken-8.5.0
```

## 📚 Documentation

- [FrankenPHP Official Docs](https://frankenphp.dev/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [PHP Workers Guide](https://frankenphp.dev/docs/workers/)

## 🛠️ Building

```bash
docker build -t my-frankenphp:latest \
  --build-arg VERSION=8.5.0 \
  --build-arg FRANKENPHP_VERSION=1.3.5 \
  .
```

## ⚡ Performance Tips

1. Enable PHP Workers for production
2. Use OPcache (already enabled)
3. Enable HTTP/3 for better performance
4. Consider using preloading for Laravel/Symfony

## 📝 Notes

This image is optimized for **development**. For production:
- Remove Xdebug
- Configure proper security headers
- Use production Caddyfile
- Enable workers for better performance
