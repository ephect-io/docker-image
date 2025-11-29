# PHP 8.4.15 - apache

**Date de build:** 2025-11-29 19:01:55
**Architecture:** x86_64
**Tag:** `localhost:5000/dev-php:apache-8.4.15`

---

## 📋 Rapport de Build

✅ User setup
✅ PHP configuration
✅ Xdebug
✅ Dev tools
✅ Zip extension
✅ Composer
✅ NVM and Node.js

---

## 🐳 Informations de l'image

```bash
# Taille de l'image
1.55GB

# ID de l'image
0e50fc424d4e
```

## 📦 Utilisation

```bash
# Lancer un conteneur
docker run -it --rm localhost:5000/dev-php:apache-8.4.15 bash

# Vérifier PHP
docker run --rm localhost:5000/dev-php:apache-8.4.15 php --version

# Vérifier Composer
docker run --rm localhost:5000/dev-php:apache-8.4.15 composer --version

# Vérifier Node.js (en tant que salamandra)
docker run --rm -u salamandra localhost:5000/dev-php:apache-8.4.15 bash -c "source ~/.bashrc && node --version"
```

## 🔧 Extensions PHP installées

```bash
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

