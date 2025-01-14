#!/bin/bash

# Flags possible:
# -e for edition. Example: -eEE
# -u asks to run the update at the end of this part or not

edition="CE"
update="true"

while getopts e:u: flag; do
  case "${flag}" in
  e) edition=${OPTARG} ;;
  u) update=${OPTARG} ;;
  *) ;;
  esac
done

git clone https://github.com/OXID-eSales/oxideshop_ce.git --branch=b-8.0.x source

# Configure containers
perl -pi -e 's#error_reporting = .*#error_reporting = E_ALL ^ E_WARNING ^ E_DEPRECATED#g;' \
  containers/php/custom.ini

perl -pi -e 's#/var/www/#/var/www/source/#g;' \
  containers/httpd/project.conf

# Configure shop
cp source/source/config.inc.php.dist source/source/config.inc.php

perl -pi -e 'print "SetEnvIf Authorization \"(.*)\" HTTP_AUTHORIZATION=\$1\n\n" if $. == 1' \
  source/source/.htaccess

perl -pi -e 's#<dbHost>#mysql#g;' \
  -e 's#<dbUser>#root#g;' \
  -e 's#<dbName>#example#g;' \
  -e 's#<dbPwd>#root#g;' \
  -e 's#<dbPort>#3306#g;' \
  -e 's#<sShopURL>#http://localhost.local/#g;' \
  -e 's#<sShopDir>#/var/www/source/#g;' \
  -e 's#<sCompileDir>#/var/www/source/tmp/#g;' \
  source/source/config.inc.php

# Start all containers
make up

# Update composer to 2.4+
docker-compose exec php sudo composer self-update --2

if [ $edition = "PE" ]; then
  docker-compose exec \
    php composer config repositories.oxid-esales/oxideshop-pe \
    --json '{"type":"git", "url":"https://github.com/OXID-eSales/oxideshop_pe"}'
  docker-compose exec php composer require oxid-esales/oxideshop-pe:dev-b-8.0.x --no-update
fi

if [ $edition = "EE" ]; then
  docker-compose exec \
    php composer config repositories.oxid-esales/oxideshop-pe \
    --json '{"type":"git", "url":"https://github.com/OXID-eSales/oxideshop_pe"}'
  docker-compose exec php composer require oxid-esales/oxideshop-pe:dev-b-8.0.x --no-update

  docker-compose exec \
    php composer config repositories.oxid-esales/oxideshop-ee \
    --json '{"type":"git", "url":"https://github.com/OXID-eSales/oxideshop_ee"}'
  docker-compose exec php composer require oxid-esales/oxideshop-ee:dev-b-8.0.x --no-update
fi

if [ $update = true ]; then
  docker-compose exec php composer update --no-plugins --no-scripts
fi
