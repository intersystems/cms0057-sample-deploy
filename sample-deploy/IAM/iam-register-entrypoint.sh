#!/bin/sh
 
# Install jq for JSON parsing
apk add --no-cache jq
 
# Load configuration from JSON
CONFIG_FILE="/iam-services-config.JSON"
 
DEVICE=/dev/stdout
 
if [ -f /tmp/initialized.dat ];
then
    exit 0
else
    atime=5
    printf "\n[DEMO] waiting ${atime}s ..." >> $DEVICE
    sleep ${atime}
    printf " done!" >> $DEVICE
 
    NUM_SERVICES=$(jq '.services | length' $CONFIG_FILE)
 
    for i in $(seq 0 $(($NUM_SERVICES - 1))); do
        # Register service
        SERVICE_NAME=$(jq -r ".services[$i].name" $CONFIG_FILE)
        SERVICE_URL=$(jq -r ".services[$i].url" $CONFIG_FILE)
        INSTANCE_WEBGATEWAY_HOSTNAME=$(jq -r ".services[$i].hostname" $CONFIG_FILE)
        INSTANCE_WEBGATEWAY_PORT=$(jq -r ".services[$i].port" $CONFIG_FILE)
        curl -i -X POST --url https://${IAM_HOSTNAME}:${IAM_PORT}/services/ -u ${IAM_USER}:${IAM_USER_PWD} --data "name=${SERVICE_NAME}" --data "url=https://${INSTANCE_WEBGATEWAY_HOSTNAME}:${INSTANCE_WEBGATEWAY_PORT}${SERVICE_URL}" --cacert /certs/tls.crt >> $DEVICE
     
        # Register routes for the service
        NUM_ROUTES=$(jq ".services[$i].routes | length" $CONFIG_FILE)
 
        for j in $(seq 0 $(($NUM_ROUTES - 1))); do
            ROUTE_NAME=$(jq -r ".services[$i].routes[$j].name" $CONFIG_FILE)
            ROUTE_PATHS=$(jq -c ".services[$i].routes[$j].paths[]" $CONFIG_FILE | xargs | tr ' ' ',')
            ROUTE_PROTOCOLS=$(jq -c ".services[$i].routes[$j].protocols[]" $CONFIG_FILE | xargs | tr ' ' ',')
            ROUTE_STRIP_PATH=$(jq -r ".services[$i].routes[$j].strip_path" $CONFIG_FILE)
             
            # Constructing curl command for the route
            curl -i -X POST --url https://${IAM_HOSTNAME}:${IAM_PORT}/services/${SERVICE_NAME}/routes -u ${IAM_USER}:${IAM_USER_PWD} --data "name=${ROUTE_NAME}" --data "protocols[]=${ROUTE_PROTOCOLS}" --data "paths[]=${ROUTE_PATHS}" --data "strip_path=${ROUTE_STRIP_PATH}" --cacert /certs/tls.crt >> $DEVICE
        done
    done
    touch /tmp/initialized.dat
exit 0
fi
exit 1