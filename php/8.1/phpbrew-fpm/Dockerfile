FROM debian:bullseye-slim

LABEL MAINTAINER "David Blanchard <david.blanchard@cewe.fr>"

ENV DEBIAN_FRONTEND "noninteractive"

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Configure apt and install packages
RUN apt-get update && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    && apt-get -y install git openssh-client inetutils-tools inetutils-ping less iproute2 procps lsb-release libzip-dev zip unzip bc libtidy-dev libpng-dev \
    curl gnupg locales zsh wget fonts-powerline \

# Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && usermod -a -G www-data $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME 

ENV TZ "Europe/Paris"

RUN apt-get install -y --no-install-recommends \
 # phpbrew used tools
 curl wget git ca-certificates \
 # phpbrew runtime
 php7.4-cli php7.4-phar php7.4-json php7.4-readline php7.4-bz2 \
 # timezone data
 tzdata

# configure timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install phpbrew binary
RUN wget -q -O /usr/bin/phpbrew https://raw.githubusercontent.com/phpbrew/phpbrew/master/phpbrew \
 && chmod +x /usr/bin/phpbrew

# install base build dependencies for php
RUN apt-get install  -y --no-install-recommends \
 build-essential pkg-config bison autoconf automake autotools-dev re2c

# install extension build dependencies for php
RUN apt-get install -y --no-install-recommends \
    # pcre extension
    libpcre3-dev \
    # for compression
    libbz2-dev \
    # zip extension
    libzip4 libzip-dev \
    # readline extension
    libreadline-dev \
    libedit-dev libedit2 \
    # xml related dependencies
    libxml2 libxml2-dev \
    libxslt-dev libxslt1.1 \
    # openssl dependencies
    libssl-dev openssl \
    # curl extension dependencies
    libcurl4 libcurl4-openssl-dev \
    # threads
    libonig-dev libpthread-stubs0-dev \
    # SQLite
    libsqlite3-dev  \
    # npm nodejs
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
    SHELL ["/bin/bash", "-c"]

# generate locale for agnoster
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && /usr/sbin/locale-gen

# set home
ENV HOME=/home/$USER_NAME

# the user we're applying this too (otherwise it most likely install for root)
USER $USER_NAME

# phpbrew root stores the php installation
ENV PHPBREW_ROOT=$HOME/.phpbrew

# phpbrew home stores the user preference
ENV PHPBREW_HOME=$HOME/.phpbrew

ENV PHPBREW_BIN=$HOME/.phpbrew/bin

# enable bash prompt
ENV PHPBREW_SET_PROMPT=1

# init and setup phpbrew
RUN phpbrew init \
 && echo 'source $HOME/.phpbrew/bashrc' >> $HOME/.bashrc

ARG PHP_VERSION=8.1.9
ARG PHP_DIST_NAME=$PHP_VERSION
ARG PHP_MIRROR=https://www.mirrorservice.org/sites/www.php.net/
ARG DOWNLOADER=wget
ARG PHP_VARIANTS="+bcmath +calendar +ctype +dom +fileinfo +fpm +ipc +mhash +openssl +pcre +pdo +pear +readline +sockets +sqlite +tokenizer +zip"

# predownload the distribution file
RUN source ~/.phpbrew/bashrc \
 && phpbrew download --downloader $DOWNLOADER $PHP_VERSION

# extract and install php
RUN source ~/.phpbrew/bashrc \
 && phpbrew --debug install --downloader $DOWNLOADER --stdout \
              $PHP_VERSION as $PHP_DIST_NAME \
              +cli +phar +curl +json +bz2 +xml +filter +hash +mbregex +mbstring +posix +pcntl $PHP_VARIANTS \
              #+bcmath +bz2 +calendar +cli +ctype +dom +fileinfo +filter +fpm +ipc +json +mbregex +mbstring +mhash +pcntl +pcre +pdo +pear +phar +posix +readline +sockets +tokenizer +xml +curl +openssl +zip +sqlite -- --enable-zts \
 && phpbrew use $PHP_DIST_NAME \
 && which php \
 && php -v \
 && phpbrew info \
 && mkdir -p /src/php \
 && ln -s $HOME/.phpbrew/build/$PHPBREW_PHP /src/php/$PHPBREW_PHP

ENV PHPBREW_PHP=$PHP_DIST_NAME
ENV PATH=$HOME/.phpbrew/php/$PHP_DIST_NAME/bin:$PATH

# oh-my-zsh

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

ENV TERM=xterm

# Set the default shell to bash rather than sh
ENV SHELL=/bin/zsh

# run the installation script  
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
    # install powerlevel10k
    && git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k \
    && cd $HOME && curl -fsSLO https://raw.githubusercontent.com/romkatv/dotfiles-public/master/.purepower

# zsh configuration
#ADD .zshrc $HOME 

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    php composer-setup.php \
    php -r "unlink('composer-setup.php');"

EXPOSE 9000
ENTRYPOINT []
CMD /bin/sh -c "while sleep 1000; do :; done"
