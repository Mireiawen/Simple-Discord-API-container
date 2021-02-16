# Source images
FROM "bitnami/minideb:buster" as minideb
FROM "composer:latest" as composer

########################################################################
# Build the composer application
FROM "php:8.0-cli" AS build-composer

# Install the installer script
COPY --from=minideb \
	"/usr/sbin/install_packages" \
	"/usr/sbin/install_packages"

# Install the composer
COPY --from=composer \
	"/usr/bin/composer" \
	"/usr/bin/composer"

# Install Git for composer
RUN install_packages "git"

# Install Zip for composer
RUN \
	install_packages "zlib1g-dev" "libzip-dev" "unzip" && \
	docker-php-ext-install "zip"

# Install the Gettext extension
RUN docker-php-ext-install \
	"gettext"

# Copy the application
RUN mkdir "/app"
COPY "index.php" "/app/"
COPY "composer.json" "/app/composer.json"
COPY "composer.lock" "/app/composer.lock"

# Install the composer requirements
WORKDIR "/app"
RUN composer "install" --no-interaction --no-progress \
	--no-dev

########################################################################
# The main image
FROM "php:8.0-apache"
SHELL [ "/bin/bash", "-e", "-u", "-o", "pipefail", "-c" ]

# Add the labels for the image

# Install the installer script
COPY --from=minideb \
	"/usr/sbin/install_packages" \
	"/usr/sbin/install_packages"

# Set the PHP production configuration
RUN mv \
	"$PHP_INI_DIR/php.ini-production" \
	"$PHP_INI_DIR/php.ini"

# Install the Gettext extension
RUN docker-php-ext-install \
	"gettext"

# Copy the app
COPY --from=build-composer \
	"/app/" \
	"/var/www/html"
