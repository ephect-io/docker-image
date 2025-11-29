# PHP 8.5.0 - apache

**Date de build:** 2025-11-29 18:04:17
**Architecture:** x86_64
**Tag:** `localhost:5000/dev-php:apache-8.5.0`

---

## 📋 Rapport de Build

✅ User setup
✅ PHP configuration
❌ Xdebug
✅ System packages
✅ Zip extension
✅ Composer
✅ NVM and Node.js

---

## 🐳 Informations de l'image

```bash
# Taille de l'image
1.57GB

# ID de l'image
71e2fb19fa43
```

## 📦 Utilisation

```bash
# Lancer un conteneur
docker run -it --rm localhost:5000/dev-php:apache-8.5.0 bash

# Vérifier PHP
docker run --rm localhost:5000/dev-php:apache-8.5.0 php --version

# Vérifier Composer
docker run --rm localhost:5000/dev-php:apache-8.5.0 composer --version

# Vérifier Node.js (en tant que salamandra)
docker run --rm -u salamandra localhost:5000/dev-php:apache-8.5.0 bash -c "source ~/.bashrc && node --version"
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

