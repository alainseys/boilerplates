#!/bin/bash
# PURPOSE: Ask the user for the range that needs to be used within the cluster and apply

# Function to create the configuration file
create_ip_file() {
    local ip_address_range="$1"
    local filename="metallb.yaml"
    local fnlayer2="layer2.yaml"

    # Define the content with the placeholder [IP] and [CLUSTER_NAME]
    cat <<EOL > "$fnlayer2"
        apiVersion: metallb:io/v1beta1
        metadata:
            name: first-pool
            namespace: metallb-system
    EOL
    cat <<EOL > "$filename"
apiVersion: v1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - $ip_address_range
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $ip_address_range
EOL


    echo "Configuration file '$filename' created with range: $ip_address_range"
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
    kubectl create -f $filename
    kubectl get namespace  | grep metallb-system 
}

# Main script execution
read -p "Please enter the ip range:(example 192.168.10.1-192.168.1.20) " ip_address_range


# Validate the IP address (basic validation)
create_ip_file $ip_address_range
