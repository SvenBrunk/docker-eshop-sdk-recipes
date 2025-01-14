#!/bin/bash

SCRIPT_PATH=$(dirname ${BASH_SOURCE[0]})

cd $SCRIPT_PATH/../../../../ || exit

# Prepare services configuration
make setup
make addbasicservices
make file=services/node.yml addservice
make file=services/selenium-chrome.yml addservice

perl -pi\
  -e 's#node:latest#node:12#g;'\
  docker-compose.yml

$SCRIPT_PATH/../../parts/b-7.0.x/start_shop.sh -eCE
$SCRIPT_PATH/../../parts/b-7.0.x/require_twig_components.sh -eCE

# Configure modules in composer
git clone https://github.com/OXID-eSales/module-template.git --branch=b-7.0.x source/source/modules/oe/moduletemplate
docker-compose exec -T \
  php composer config repositories.oxid-esales/module-template \
  --json '{"type":"path", "url":"./source/modules/oe/moduletemplate", "options": {"symlink": true}}'
docker-compose exec -T php composer require oxid-esales/module-template:* --no-update

docker-compose exec -T \
  php composer config repositories.oxid-esales/oxideshop-demodata-ce \
  --json '{"type":"git", "url":"https://github.com/OXID-eSales/oxideshop_demodata_ce"}'
docker-compose exec -T php composer require oxid-esales/oxideshop-demodata-ce:dev-b-7.0.x --no-update

# Install all preconfigured dependencies
docker-compose exec -T php composer update --no-interaction

$SCRIPT_PATH/../../parts/b-7.0.x/reset_database.sh -eCE
docker-compose exec -T php bin/oe-console oe:setup:demodata
docker-compose exec -T php bin/oe-console oe:admin:create --admin-email='admin@admin.com' --admin-password='admin'

docker-compose exec -T php bin/oe-console oe:module:activate oe_moduletemplate
docker-compose exec -T php bin/oe-console oe:theme:activate twig

echo "Done! Admin login: admin@admin.com Password: admin"
