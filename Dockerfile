FROM php:8.3-fpm

# Copy composer.lock and composer.json
COPY composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mariadb-client \
    libpng-dev \
    libjpeg62-turbo-dev \
libonig-dev \
    libfreetype6-dev \
    locales \
    libtidy-dev \
    libzip-dev \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    nano \
    libicu-dev \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd



# Install Node.js packages
RUN apk add --no-cache libc-dev

# Install Node.js using official source
RUN curl -sL https://deb.nodesource.com/setup_$NODE_VERSION | bash -

# Install Node.js and npm
RUN apk add --no-cache nodejs

# Install yarn globally
RUN npm install -g yarn

# Copy dependencies (if any)
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
# COPY ./ /var/www

# Copy existing application directory permissions
# COPY --chown=www:www ./ /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

