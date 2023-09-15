#!/bin/sh

TOKEN=$1
PORT=$2

IPFS_URL=http://localhost:9094
HLF_URL=http://localhost:${PORT}

print_title() {
    echo "******************** $1 ********************"
}

upload_HLF() {
    response=$(curl -sS -X POST ${HLF_URL}/invoke/traceability/lot -H "Authorization: Bearer $TOKEN" -d '{"method": "LotContract:addFiles", "args":["{\"geolocation\":\"'${1}'\", \"coldchain\":\"'${2}'\"}"]}' 2>&1)
    if [ $? -ne 0 ] ; then
        echo "ERROR: "$response""
        return 0
    fi
    message=$(echo $response | jq -r '.message')
    if [ "$message" != null ] ; then
        echo "ERROR: "$response""
        echo "ERROR: Los hashes no se subieron a la blockchain"
        return 0
    fi
    echo "INFO: Los hashes se subieron a la blockchain correctamente"
}

upload_IPFS(){
    response=$(curl -sS -F "file=@$1" $IPFS_URL/add 2>&1)
    if [ $? -ne 0 ] ; then
        echo "ERROR: "$response""
        echo "ERROR: El archivo no se pudo cargar al servidor IPFS"
        return 0
    fi
    echo "INFO: El archivo se cargó correctamente en el servidor IPFS"
    # hash=$(echo $response | jq -r '.cid[]')
    hash=$(echo $response | jq -r '.cid')
    echo "INFO: El hash del archivo es "$hash""
    HASH=$hash
}

upload_BACKUP(){
    FECHA=`date +"%d%m%Y"`
    if [ -z "${1##*geolocation*}"  ]; then
        echo "INFO: El archivo de geolocation se subió a ~fishnet/backup/"${FECHA}GEO.csv""
        mv $1 ~/fishnet/backup/${FECHA}GEO.csv
    else
        if [ -z "${1##*temperature*}" ]; then
            echo "INFO: El archivo de temperature se subió a ~fishnet/backup/"${FECHA}TEM.csv""
            mv $1 ~/fishnet/backup/${FECHA}TEM.csv
        else
            echo "ERROR: Archivos incorrectos"
        fi
    fi
}

print_title "SUBIENDO ARCHIVO GEOLOCALIZACIÓN EN IPFS"
upload_IPFS ~/fishnet-data/geolocation.csv
GEOLOCATION_HASH=$HASH

print_title "GENERANDO BACKUP DE ARCHIVO GEOLOCALIZACIÓN"
upload_BACKUP ~/fishnet-data/geolocation.csv

print_title "SUBIENDO ARCHIVO TEMPERATURA EN IPFS"
upload_IPFS ~/fishnet-data/temperature.csv
COLDCHAIN_HASH=$HASH

print_title "GENERANDO BACKUP DE ARCHIVO TEMPERATURA"
upload_BACKUP ~/fishnet-data/temperature.csv

# if [[ ! -z "${GEOLOCATION_HASH}" && ! -z "${COLDCHAIN_HASH}" ]] ; then
#     print_title "TRANSFIRIENDO A LA BLOCKCHAIN"
#     upload_HLF $GEOLOCATION_HASH $COLDCHAIN_HASH
# fi

if [ ! -z "${GEOLOCATION_HASH}" ]; then 
    if [ ! -z "${COLDCHAIN_HASH}" ]; then 
        print_title "TRANSFIRIENDO A LA BLOCKCHAIN"
        upload_HLF $GEOLOCATION_HASH $COLDCHAIN_HASH
    fi
fi