#!/bin/bash

# Composer Install shell script
#
# This shell script runs `composer install` if either the `composer.lock` file or
# the `vendor/` directory is not present`
#
# @author    nystudio107
# @copyright Copyright (c) 2022 nystudio107
# @link      https://nystudio107.com/
# @license   MIT

# Ensure permissions on directories Craft needs to write to
chown -R www-data:www-data /var/www/project/storage
chown -R www-data:www-data /var/www/project/web/cpresources
# Check for `composer.lock` & `vendor/`
cd /var/www/project
if [ ! -f "composer.lock" ] || [ ! -d "vendor" ]; then
    su-exec www-data composer install --verbose --no-progress --no-scripts --no-interaction
    # Wait until the MySQL db container responds
    echo "### Waiting for MySQL database"
    until eval "mysql -h mysql -u  -p$CRAFT_DB_PASSWORD $CRAFT_DB_DATABASE -e 'select 1' > /dev/null 2>&1"
    do
        sleep 1
    done
    # Run any pending migrations/project config changes
    su-exec www-data php craft up
fi
