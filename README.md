# development-oxid-recipes
Oxid eShop setup recipes

## Prerequirements

1. Check if other docker project is stopped! If you have something running, ports may conflict and nothing will work as intended, just take a minute and stop everything before running this!

2. You should have docker and docker-compose installed on your machine.

3. It should be some Linux or Mac :) No idea if it will work with Windows at all.

## Installation instructions:

Clone the environment and recipes first
```
mkdir myNewShinyProject && cd myNewShinyProject
git clone https://github.com/Fresh-Advance/development.git .
git clone https://github.com/Fresh-Advance/development-oxid-recipes.git recipes/oxid-esales
```

Run the recipe, for example:
```
./recipes/oxid-esales/b-6.4.x-ce-dev/run.sh
```

## Recipe Specifics

Any recipe outcome can have its own specifics. Read carefully before breaking your leg :)

### b-6.4.x-ce-dev instructions

Running old selenium tests examples:

```
# docker default run:
docker-compose exec -T -e SELENIUM_SERVER_IP=seleniumfirefox php vendor/bin/runtests-selenium

# run from the php container:
SELENIUM_SERVER_IP=seleniumfirefox vendor/bin/runtests-selenium

#run from the php container with specific group:
SELENIUM_SERVER_IP=seleniumfirefox vendor/bin/runtests-selenium AllTestsSelenium --group=sieg
```