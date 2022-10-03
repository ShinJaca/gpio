#!/usr/bin/env bash

VM=$1
DIR=$2
DEST=$3
PORT=5022



if [[ -n "$4" ]]; then
    PORT=$4
fi

if [[ -z "${VM}" ]]; then
    echo "Apelido de VM vazio!!"
    exit 1
fi

if [[ -z "${DIR}" ]]; then
    echo "Diretório não especificado!!"
    exit 1
fi

if [[ -z "${DEST}" ]]; then
    echo "Diretório de destino não especificado!!"
    exit 1
fi


for i in $DIR*; do
    scp -i ~/.ssh/id_rsa -P $PORT $i $VM:$DEST 
done
