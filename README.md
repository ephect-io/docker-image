# 🐳 PHP Development Images

Optimized PHP Docker images for development with Apache/FPM/ZTS, including Xdebug, Composer, NVM and Node.js LTS.

**Last update:** 2025-11-30 21:36:22  
**Architecture:** x86_64  
**Registry:** [ephect/dev-php](https://hub.docker.com/r/ephect/dev-php)

---

## 📦 Available Images

| Package | Version | Pull Command | Size | Build Status |
|---------|---------|--------------|------|--------------|
| **apache** | 8.5.0 | `docker pull localhost:5000/dev-php:apache-8.5.0` | 1.57GB | ✅ Available |
| **apache** | 8.4.15 | `docker pull localhost:5000/dev-php:apache-8.4.15` | 1.55GB | ✅ Available |
| **apache** | 8.3.28 | `docker pull localhost:5000/dev-php:apache-8.3.28` | 1.54GB | ✅ Available |
| **apache** | 8.2.29 | `docker pull localhost:5000/dev-php:apache-8.2.29` | 1.53GB | ✅ Available |
| **apache** | 8.1.33 | `docker pull localhost:5000/dev-php:apache-8.1.33` | 1.53GB | ✅ Available |

---

## 🚀 Quick Start

### Apache (mod_php)

```bash
# Pull image
docker pull localhost:5000/dev-php:apache-8.5.0

# Start a container
docker run -d -p 8080:80 -v $(pwd):/var/www/html localhost:5000/dev-php:apache-8.5.0

# Access container
docker exec -it <container_id> bash
```

### FPM (FastCGI Process Manager)

```bash
# Pull image
docker pull localhost:5000/dev-php:fpm-8.5.0

# Start with nginx
docker run -d -p 9000:9000 -v $(pwd):/var/www/html localhost:5000/dev-php:fpm-8.5.0
```

### ZTS (Zend Thread Safety)

```bash
# Pull image
docker pull localhost:5000/dev-php:zts-8.5.0

# Start a container
docker run -it --rm localhost:5000/dev-php:zts-8.5.0 bash
```

---

## ✨ Features

### 🔧 Pre-installed Tools

- **PHP** - Specified version (8.4.x, 8.5.x, etc.)
- **Composer** - PHP dependency manager
- **Xdebug** - PHP debugger and profiler
- **NVM** - Node Version Manager
- **Node.js LTS** - Latest LTS version
- **npm** - Node.js package manager
- **Git** - Version control
- **Vim** - Text editor

### 📦 Included PHP Extensions

- Core extensions (json, mbstring, xml, etc.)
- **Xdebug** - Debugging and code coverage
- **Zip** - Compression/decompression
- **PDO** - Database support
- **OPcache** - Opcode cache

### 👤 User Configuration

- User: `salamandra` (UID: 1000)
- Sudo access without password
- Member of `www-data` group

---

## 🔍 Image Details


### APACHE


#### PHP 8.5.0 - apache

**Tag:** `localhost:5000/dev-php:apache-8.5.0`  
**Size:** 1.57GB  
**Image ID:** 71e2fb19fa43

**Build Log:**

✅ User setup
✅ PHP configuration
❌ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js


<details>
<summary>📦 Installed PHP Extensions</summary>

```
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
hash
iconv
json
lexbor
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
uri
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache

```

</details>

---


#### PHP 8.4.15 - apache

**Tag:** `localhost:5000/dev-php:apache-8.4.15`  
**Size:** 1.55GB  
**Image ID:** 0e50fc424d4e

**Build Log:**

✅ User setup
✅ PHP configuration
✅ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js


<details>
<summary>📦 Installed PHP Extensions</summary>

```
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache

```

</details>

---


#### PHP 8.3.28 - apache

**Tag:** `localhost:5000/dev-php:apache-8.3.28`  
**Size:** 1.54GB  
**Image ID:** 636b8870e589

**Build Log:**

✅ User setup
✅ PHP configuration
✅ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js


<details>
<summary>📦 Installed PHP Extensions</summary>

```
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache

```

</details>

---


#### PHP 8.2.29 - apache

**Tag:** `localhost:5000/dev-php:apache-8.2.29`  
**Size:** 1.53GB  
**Image ID:** 730576edafed

**Build Log:**

✅ User setup
✅ PHP configuration
✅ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js


<details>
<summary>📦 Installed PHP Extensions</summary>

```
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
random
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache

```

</details>

---


#### PHP 8.1.33 - apache

**Tag:** `localhost:5000/dev-php:apache-8.1.33`  
**Size:** 1.53GB  
**Image ID:** 812d1e25b65b

**Build Log:**

✅ User setup
✅ PHP configuration
✅ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js


<details>
<summary>📦 Installed PHP Extensions</summary>

```
[PHP Modules]
Core
ctype
curl
date
dom
fileinfo
filter
ftp
hash
iconv
json
libxml
mbstring
mysqlnd
openssl
pcre
PDO
pdo_sqlite
Phar
posix
readline
Reflection
session
SimpleXML
sodium
SPL
sqlite3
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache

```

</details>

---


## 🔗 Useful Links

- [PHP Official Images](https://hub.docker.com/_/php)
- [Composer](https://getcomposer.org/)
- [Xdebug Documentation](https://xdebug.org/docs/)
- [NVM](https://github.com/nvm-sh/nvm)
- [Node.js](https://nodejs.org/)

## 📝 Notes

These images are designed for **development** as Xdebug is enabled by default.

## 🐳 Local Docker Registry

I prepared a script called `rocker` (Registry for Docker) to easily create and manage a local Docker registry on your machine. This is useful for testing and development purposes.

See the [Rocker README](./registry/README.md) for detailed instructions on usage and configuration.
