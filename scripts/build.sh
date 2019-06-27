#/bin/bash

cwd=${PWD};
f=${1};

for a in php[0-9][0-9]; do
    if [ -n "${f}" ] && [ "${f}" != "${a}" ]; then
        continue;
    fi

    tag=$a-fpm;
    cd ${cwd}/$a/fpm;
    docker build --tag=srcoder/development-php:${tag} . || exit 1;
done

cd ${cwd};

