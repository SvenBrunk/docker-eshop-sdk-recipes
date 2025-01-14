#!/bin/bash

# Flags possible:
# -e for edition. Possible values: CE/PE/EE
# -b for theme repository branch

while getopts e:b: flag; do
  case "${flag}" in
  e) edition=${OPTARG} ;;
  b) branch=${OPTARG} ;;
  *) ;;
  esac
done

if [ -z ${edition+x} ] || [ -z ${branch+x} ]; then
  echo -e "\e[1;31mThe edition (-e) and branch (-b) are required for require_twig_components.sh\e[0m"
  exit 1
fi

# Configure twig themes in composer
docker-compose exec -T \
  php composer config repositories.oxid-esales/twig-component \
  --json '{"type":"git", "url":"https://github.com/OXID-eSales/twig-component"}'
docker-compose exec -T php composer require oxid-esales/twig-component:dev-${branch} --no-update

if [ $edition = "PE" ] || [ $edition = "EE" ]; then
  docker-compose exec -T \
    php composer config repositories.oxid-esales/twig-component-pe \
    --json '{"type":"git", "url":"https://github.com/OXID-eSales/twig-component-pe"}'
  docker-compose exec -T php composer require oxid-esales/twig-component-pe:dev-${branch} --no-update
fi

if [ $edition = "EE" ]; then
  docker-compose exec -T \
    php composer config repositories.oxid-esales/twig-component-ee \
    --json '{"type":"git", "url":"https://github.com/OXID-eSales/twig-component-ee"}'
  docker-compose exec -T php composer require oxid-esales/twig-component-ee:dev-${branch} --no-update
fi

"$(dirname $0)/require_theme.sh" -t"twig-admin" -b${branch}
