#!/bin/bash

set -e

local cluster_name="$1"
read -p "Enter the name of the cluster: " cluster_name
## The following commented environment variables should be set./
## before running this script

export GOVC_USERNAME='user@vsphere.local'
export GOVC_PASSWORD='password'
export GOVC_INSECURE=true
export GOVC_URL='https://vcenter.domain.com'
export GOVC_DATASTORE='DS01'
export GOVC_NETWORK='kubernetes'
export GOVC_DATACENTER='DC1'

CLUSTER_NAME=${CLUSTER_NAME:=$cluster_name}
TALOS_VERSION=${TALOS_VERSION:=v1.9.5}
OVA_PATH=${OVA_PATH:="https://factory.talos.dev/image/903b2da78f99adef03cbbd4df6714563823f63218508800751560d3bc3557e40/${TALOS_VERSION}/vmware-amd64.ova"}

CONTROL_PLANE_COUNT=${CONTROL_PLANE_COUNT:=3}
CONTROL_PLANE_CPU=${CONTROL_PLANE_CPU:=2}
CONTROL_PLANE_MEM=${CONTROL_PLANE_MEM:=4096}
CONTROL_PLANE_DISK=${CONTROL_PLANE_DISK:=10G}
CONTROL_PLANE_MACHINE_CONFIG_PATH=${CONTROL_PLANE_MACHINE_CONFIG_PATH:="./controlplane.yaml"}

WORKER_COUNT=${WORKER_COUNT:=2}
WORKER_CPU=${WORKER_CPU:=2}
WORKER_MEM=${WORKER_MEM:=4096}
WORKER_DISK=${WORKER_DISK:=10G}
WORKER_MACHINE_CONFIG_PATH=${WORKER_MACHINE_CONFIG_PATH:="./worker.yaml"}

upload_ova () {
    ## Import desired Talos Linux OVA into a new content library
    govc library.create ${CLUSTER_NAME}
    govc library.import -n talos-${TALOS_VERSION} ${CLUSTER_NAME} ${OVA_PATH}
}

create () {
    ## Encode machine configs
    CONTROL_PLANE_B64_MACHINE_CONFIG=$(cat ${CONTROL_PLANE_MACHINE_CONFIG_PATH}| base64 | tr -d '\n')
    WORKER_B64_MACHINE_CONFIG=$(cat ${WORKER_MACHINE_CONFIG_PATH} | base64 | tr -d '\n')

    ## Create control plane nodes and edit their settings
    for i in $(seq 1 ${CONTROL_PLANE_COUNT}); do
        echo ""
        echo "launching control plane node: ${CLUSTER_NAME}-control-plane-${i}"
        echo ""

        govc library.deploy ${CLUSTER_NAME}/talos-${TALOS_VERSION} ${CLUSTER_NAME}-control-plane-${i}

        govc vm.change \
        -c ${CONTROL_PLANE_CPU}\
        -m ${CONTROL_PLANE_MEM} \
        -e "guestinfo.talos.config=${CONTROL_PLANE_B64_MACHINE_CONFIG}" \
        -e "disk.enableUUID=1" \
        -vm ${CLUSTER_NAME}-control-plane-${i}

        govc vm.disk.change -vm ${CLUSTER_NAME}-control-plane-${i} -disk.name disk-1000-0 -size ${CONTROL_PLANE_DISK}

        if [ -z "${GOVC_NETWORK+x}" ]; then
             echo "GOVC_NETWORK is unset, assuming default VM Network";
        else
            echo "GOVC_NETWORK set to ${GOVC_NETWORK}";
            govc vm.network.change -vm ${CLUSTER_NAME}-control-plane-${i} -net "${GOVC_NETWORK}" ethernet-0
        fi

        govc vm.power -on ${CLUSTER_NAME}-control-plane-${i}
    done

    ## Create worker nodes and edit their settings
    for i in $(seq 1 ${WORKER_COUNT}); do
        echo ""
        echo "launching worker node: ${CLUSTER_NAME}-worker-${i}"
        echo ""

        govc library.deploy ${CLUSTER_NAME}/talos-${TALOS_VERSION} ${CLUSTER_NAME}-worker-${i}

        govc vm.change \
        -c ${WORKER_CPU}\
        -m ${WORKER_MEM} \
        -e "guestinfo.talos.config=${WORKER_B64_MACHINE_CONFIG}" \
        -e "disk.enableUUID=1" \
        -vm ${CLUSTER_NAME}-worker-${i}

        govc vm.disk.change -vm ${CLUSTER_NAME}-worker-${i} -disk.name disk-1000-0 -size ${WORKER_DISK}

        if [ -z "${GOVC_NETWORK+x}" ]; then
             echo "GOVC_NETWORK is unset, assuming default VM Network";
        else
            echo "GOVC_NETWORK set to ${GOVC_NETWORK}";
            govc vm.network.change -vm ${CLUSTER_NAME}-worker-${i} -net "${GOVC_NETWORK}" ethernet-0
        fi


        govc vm.power -on ${CLUSTER_NAME}-worker-${i}
    done

}

destroy() {
    for i in $(seq 1 ${CONTROL_PLANE_COUNT}); do
        echo ""
        echo "destroying control plane node: ${CLUSTER_NAME}-control-plane-${i}"
        echo ""

        govc vm.destroy ${CLUSTER_NAME}-control-plane-${i}
    done

    for i in $(seq 1 ${WORKER_COUNT}); do
        echo ""
        echo "destroying worker node: ${CLUSTER_NAME}-worker-${i}"
        echo ""
        govc vm.destroy ${CLUSTER_NAME}-worker-${i}
    done
}

delete_ova() {
    govc library.rm ${CLUSTER_NAME}
}

"$@"
