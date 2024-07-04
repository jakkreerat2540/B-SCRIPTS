#!/bin/bash

# Variables
EXPIRATIONDAYS=700
CASUBJSTRING="/C=MB/ST=Bangkok/L=THAI/O=Blue/OU=IT/CN=Blue.local/emailAddress=info@blue.com"

while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
        -m|--mode)
        MODE="$2"
        shift ;;
        -h|--hostname)
        NAME="$2"
        shift ;;
        -hip|--hostip)
        SERVERIP="$2"
        shift ;;
        -pw|--password)
        PASSWORD="$2"
        shift ;;
        -t|--targetdir)
        TARGETDIR="$2"
        shift ;;
        -e|--expirationdays)
        EXPIRATIONDAYS="$2"
        shift ;;
        --ca-subj)
        CASUBJSTRING="$2"
        shift ;;
        *)
        # unknown option
        ;;
    esac
    shift
done

echo "Mode: $MODE"
echo "Host/Client name: $NAME"
echo "Host IP: $SERVERIP"
echo "Target directory: $TARGETDIR"
echo "Expiration days: $EXPIRATIONDAYS"

programname=$0

function usage {
    echo "Usage: $programname -m ca|server|client -h hostname [-hip 1.2.3.4] [-pw password] -t /target/dir [-e 365] [--ca-subj subj_string]"
    echo "  -m|--mode                 'ca' to create CA, 'server' to create server cert, 'client' to create client cert"
    echo "  -h|--hostname|-n|--name   DNS hostname for the server or name of client"
    echo "  -hip|--hostip             Host's IP - default: none"
    echo "  -pw|--password            Password for CA key generation (optional)"
    echo "  -t|--targetdir            Target directory for cert files and keys"
    echo "  -e|--expirationdays       Certificate expiration in days - default: 700 days"
    echo "  --ca-subj                 Subject string for CA cert - default: Example String..."
    exit 1
}

function check_dependencies {
    for cmd in openssl; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done
}

function createCA {
    echo "Creating CA..."
    if [[ -n $PASSWORD ]]; then
        openssl genpkey -algorithm RSA -out $TARGETDIR/ca-key.pem -aes256 -pass pass:$PASSWORD -pkeyopt rsa_keygen_bits:2048
        openssl req -passin pass:$PASSWORD -new -x509 -days $EXPIRATIONDAYS -key $TARGETDIR/ca-key.pem -sha256 -out $TARGETDIR/ca.pem -subj "$CASUBJSTRING"
    else
        openssl genpkey -algorithm RSA -out $TARGETDIR/ca-key.pem -pkeyopt rsa_keygen_bits:2048
        openssl req -new -x509 -days $EXPIRATIONDAYS -key $TARGETDIR/ca-key.pem -sha256 -out $TARGETDIR/ca.pem -subj "$CASUBJSTRING"
    fi

    chmod 0400 $TARGETDIR/ca-key.pem
    chmod 0444 $TARGETDIR/ca.pem
    echo "CA creation complete."
}

function checkCAFilesExist {
    if [[ ! -f "$TARGETDIR/ca.pem" || ! -f "$TARGETDIR/ca-key.pem" ]]; then
        echo "Error: $TARGETDIR/ca.pem or $TARGETDIR/ca-key.pem not found. Create CA first with '-m ca'."
        exit 1
    fi
}

function createServerCert {
    checkCAFilesExist

    IPSTRING=""
    if [[ -n $SERVERIP ]]; then
        IPSTRING=",IP:$SERVERIP"
    fi

    echo "Creating server certificate..."
    openssl genpkey -algorithm RSA -out $TARGETDIR/server-key.pem -pkeyopt rsa_keygen_bits:2048
    openssl req -subj "/CN=$NAME" -new -key $TARGETDIR/server-key.pem -out $TARGETDIR/server.csr
    echo "subjectAltName = DNS:$NAME$IPSTRING" > $TARGETDIR/extfile.cnf

    if [[ -n $PASSWORD ]]; then
        openssl x509 -passin pass:$PASSWORD -req -days $EXPIRATIONDAYS -in $TARGETDIR/server.csr -CA $TARGETDIR/ca.pem -CAkey $TARGETDIR/ca-key.pem -CAcreateserial -out $TARGETDIR/server-cert.pem -extfile $TARGETDIR/extfile.cnf
    else
        openssl x509 -req -days $EXPIRATIONDAYS -in $TARGETDIR/server.csr -CA $TARGETDIR/ca.pem -CAkey $TARGETDIR/ca-key.pem -CAcreateserial -out $TARGETDIR/server-cert.pem -extfile $TARGETDIR/extfile.cnf
    fi

    rm $TARGETDIR/server.csr $TARGETDIR/extfile.cnf && cp $TARGETDIR/ca.pem $TARGETDIR/ca-cert.pem
    chmod 0400 $TARGETDIR/server-key.pem
    chmod 0444 $TARGETDIR/server-cert.pem
    echo "Server certificate creation complete."
}

function createClientCert {
    checkCAFilesExist

    echo "Creating client certificate..."
    openssl genpkey -algorithm RSA -out $TARGETDIR/client-key.pem -pkeyopt rsa_keygen_bits:2048
    openssl req -subj "/CN=$NAME" -new -key $TARGETDIR/client-key.pem -out $TARGETDIR/client.csr
    echo "extendedKeyUsage = clientAuth" > $TARGETDIR/extfile.cnf

    if [[ -n $PASSWORD ]]; then
        openssl x509 -passin pass:$PASSWORD -req -days $EXPIRATIONDAYS -in $TARGETDIR/client.csr -CA $TARGETDIR/ca.pem -CAkey $TARGETDIR/ca-key.pem -CAcreateserial -out $TARGETDIR/client-cert.pem -extfile $TARGETDIR/extfile.cnf
    else
        openssl x509 -req -days $EXPIRATIONDAYS -in $TARGETDIR/client.csr -CA $TARGETDIR/ca.pem -CAkey $TARGETDIR/ca-key.pem -CAcreateserial -out $TARGETDIR/client-cert.pem -extfile $TARGETDIR/extfile.cnf
    fi

    rm $TARGETDIR/client.csr $TARGETDIR/extfile.cnf $TARGETDIR/ca.srl && cp $TARGETDIR/ca.pem $TARGETDIR/ca-cert.pem
    chmod 0400 $TARGETDIR/client-key.pem
    chmod 0444 $TARGETDIR/client-cert.pem

    mv $TARGETDIR/client-key.pem $TARGETDIR/client-$NAME-key.pem
    mv $TARGETDIR/client-cert.pem $TARGETDIR/client-$NAME-cert.pem
    echo "Client certificate creation complete."
}

if [[ -z $MODE || ($MODE != "ca" && -z $NAME) || -z $TARGETDIR ]]; then
    usage
fi

check_dependencies

mkdir -p $TARGETDIR

case $MODE in
    ca)
        createCA ;;
    server)
        createServerCert ;;
    client)
        createClientCert ;;
    *)
        usage ;;
esac

