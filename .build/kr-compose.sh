#!/bin/bash
source ./kr-variable.sh
file="./runtime.release.env"

function remove_file() {
        rm $file
        rm $file'.bak' 
}

function remove_deps() {
    img=$(docker images -q)
    echo $img
    if [  $? -eq 0 ]; then
        echo 'Removing all images.'
        docker rmi $(docker images -q)
    fi

    docker volume ls -q
    if [  $? -eq 0 ]; then
        echo 'Removing all volumes.'
        docker volume  rm $(docker volume  ls -q)
    fi
}

remove_file

if [ $prune == "true" ]; then
    docker builder prune -f
fi

cp ../.docker/.env/runtime.release.env ./runtime.release.env

if [  $? -eq 0 ]; then
    echo 'Copy completed.'
    ls ./
else
   exit 1
fi

echo 'replace variable'
sid=$(uuidgen | tr '[:upper:]' '[:lower:]' | cut -c1-8)
echo "Cluster ID: $sid"
sed -i.bak -e "s/\$version/$krversion/g" \
           -e "s/\$arg/$buildArg/g" \
           -e "s/\$id/$sid/g" \
           ./runtime.release.env

if [  $? -eq 0 ]; then
    echo 'variable replacement completed.'
else
   exit 1
fi

COMPOSE_FILES="-f ../docker-compose-network.yml -f ../docker-compose-volume.yml -f ../docker-compose-components.yml"

if [ $dbInclude == 'true' ] ; then
    COMPOSE_FILES="$COMPOSE_FILES -f ../docker-compose-database.yml"
fi

if [ $eventInclude == 'true' ] ; then
    COMPOSE_FILES="$COMPOSE_FILES -f ../docker-compose-eventing.yml"
fi

if [ $printRenderedComposeFile == 'true' ]  ; then
    echo 'print replaced compose file'
    docker-compose $COMPOSE_FILES --env-file ./runtime.release.env config
fi

if [ $build == 'true' ]  ; then
    echo "Build compose version $krversion"   
    docker-compose $COMPOSE_FILES --env-file ./runtime.release.env build

    if [  $? -eq 0 ]; then
        echo "Build - $krversion completed sucessfully."
    fi
fi

if [ $compose == 'true' ]  ; then
    echo "create container layer for build version - $krversion"
    docker-compose $COMPOSE_FILES --env-file ./runtime.release.env --verbose up -d

    if [  $? -eq 0 ]; then
        echo "Service and dependencies started sucessfully."
    fi

elif [ $destroy == 'true' ]; then
    echo "destroy container layer for build version - $krversion"
    docker-compose $COMPOSE_FILES --env-file ./runtime.release.env down --volumes --remove-orphans
    remove_deps   
fi

remove_file


