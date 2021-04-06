#/bin/bash

cwd=${PWD};
f=${1};

for a in php[0-9][0-9]; do
    if [ -n "${f}" ] && [ "${f}" != "${a}" ]; then
        continue;
    fi

    tag=$a-fpm;
    cd ${cwd}/$a/fpm;
    if ! docker build --tag=srcoder/development-php:${tag} . ; then
      echo "";
      echo "Could not build $tag";
      exit 1;
    fi
done

cd ${cwd};

