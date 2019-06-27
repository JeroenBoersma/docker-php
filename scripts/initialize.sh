#/bin/bash

cwd=${PWD};
f=${1};

for a in php[0-9][0-9]; do
    if [ -n "${f}" ] && [ "${f}" != "${a}" ]; then
        continue;
    fi

    cp -rp ${cwd}/base/* $a/fpm/
    sed -e 's/{PHP_VERSION}/'$a'/' -e 's/php:php\([0-9]\)\([0-9]\)$/php:\1.\2-fpm/' -i $a/fpm/Dockerfile
done

cd ${cwd};

