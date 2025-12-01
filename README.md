# 🐳 PHP Development Images

Optimized PHP Docker images for development with Apache/FPM/ZTS, including Xdebug, Composer, NVM and Node.js LTS.

**Last update:** 2025-12-01 18:53:20  
**Architecture:** x86_64  
**Registry:** [ephect/dev-php](https://hub.docker.com/r/ephect/dev-php)

---

## 📦 Available Images

| Package | Version | Pull Command | Size | Build Status |
|---------|---------|--------------|------|--------------|
| **apache** | 8.5.0 | `docker pull ephect/dev-php:apache-8.5.0` | 1.25GB | ✅ Available |
| **apache** | 8.4.15 | `docker pull ephect/dev-php:apache-8.4.15` | 1.24GB | ✅ Available |
| **apache** | 8.3.28 | `docker pull ephect/dev-php:apache-8.3.28` | 1.23GB | ✅ Available |
| **apache** | 8.2.29 | `docker pull ephect/dev-php:apache-8.2.29` | 1.22GB | ✅ Available |
| **apache** | 8.1.33 | `docker pull ephect/dev-php:apache-8.1.33` | 1.22GB | ✅ Available |
| **fpm** | 8.5.0 | `docker pull ephect/dev-php:fpm-8.5.0` | 1.24GB | ✅ Available |
| **fpm** | 8.4.15 | `docker pull ephect/dev-php:fpm-8.4.15` | 1.22GB | ✅ Available |
| **fpm** | 8.3.28 | `docker pull ephect/dev-php:fpm-8.3.28` | 1.21GB | ✅ Available |
| **fpm** | 8.2.29 | `docker pull ephect/dev-php:fpm-8.2.29` | 1.21GB | ✅ Available |
| **fpm** | 8.1.33 | `docker pull ephect/dev-php:fpm-8.1.33` | 1.21GB | ✅ Available |
| **zts** | 8.5.0 | `docker pull ephect/dev-php:zts-8.5.0` | - | ❌ Not yet available |
| **zts** | 8.4.15 | `docker pull ephect/dev-php:zts-8.4.15` | - | ❌ Not yet available |
| **zts** | 8.3.28 | `docker pull ephect/dev-php:zts-8.3.28` | - | ❌ Not yet available |
| **zts** | 8.2.29 | `docker pull ephect/dev-php:zts-8.2.29` | - | ❌ Not yet available |
| **zts** | 8.1.33 | `docker pull ephect/dev-php:zts-8.1.33` | - | ❌ Not yet available |

---

## 🚀 Quick Start

### Apache (mod_php)

```bash
# Pull image
docker pull ephect/dev-php:apache-8.5.0

# Start a container
docker run -d -p 8080:80 -v $(pwd):/var/www/html ephect/dev-php:apache-8.5.0

# Access container
docker exec -it <container_id> bash
```

### FPM (FastCGI Process Manager)

```bash
# Pull image
docker pull ephect/dev-php:fpm-8.5.0

# Start with nginx
docker run -d -p 9000:9000 -v $(pwd):/var/www/html ephect/dev-php:fpm-8.5.0
```

### ZTS (Zend Thread Safety)

```bash
# Pull image
docker pull ephect/dev-php:zts-8.5.0

# Start a container
docker run -it --rm ephect/dev-php:zts-8.5.0 bash
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

**Tag:** `ephect/dev-php:apache-8.5.0`  
**Size:** 1.25GB  
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

**Tag:** `ephect/dev-php:apache-8.4.15`  
**Size:** 1.24GB  
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

**Tag:** `ephect/dev-php:apache-8.3.28`  
**Size:** 1.23GB  
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

**Tag:** `ephect/dev-php:apache-8.2.29`  
**Size:** 1.22GB  
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

**Tag:** `ephect/dev-php:apache-8.1.33`  
**Size:** 1.22GB  
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


### FPM


#### PHP 8.5.0 - fpm

**Tag:** `ephect/dev-php:fpm-8.5.0`  
**Size:** 1.24GB  
**Image ID:** ece4372c648a

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


#### PHP 8.4.15 - fpm

**Tag:** `ephect/dev-php:fpm-8.4.15`  
**Size:** 1.22GB  
**Image ID:** 837870ae011e

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


#### PHP 8.3.28 - fpm

**Tag:** `ephect/dev-php:fpm-8.3.28`  
**Size:** 1.21GB  
**Image ID:** 5432926651f4

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


#### PHP 8.2.29 - fpm

**Tag:** `ephect/dev-php:fpm-8.2.29`  
**Size:** 1.21GB  
**Image ID:** 39f7792d1ec8

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


#### PHP 8.1.33 - fpm

**Tag:** `ephect/dev-php:fpm-8.1.33`  
**Size:** 1.21GB  
**Image ID:** 851901ed7488

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


### ZTS

No zts images are currently available.


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

See the [Rocker README](https://github.com/ephect-io/docker-image/blob/main/registry/README.md) for detailed instructions on usage and configuration.
## 🐳 Devcontainer setup

I prepared devcontainer configurations for Apache and Nginx/FPM to easily set up a development environment.

See the [Devcontainer README](https://github.com/ephect-io/docker-image/blob/main/devcontainer/README.md) for detailed instructions on usage and configuration.
