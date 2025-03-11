#!/bin/bash
# TITLE: setup.sh
# PROJECT: Kubernetes
# DESCRIPTION: Automated instlalation procedure to provision vcenter vms with talos and create a kubernets cluster
# DATE: 2025-03-11
# VERSION: v0.0.1
# NOTES: DO NOT USE THIS SCRIPT IN PRODUCTION NOT FULLY TESTED ON HA !!!
# Function to execute script and check for errors
execute_script() {
  local script="$1"
  echo "Executiong $script..."
  bash "$script"
  if [ $? -ne 0 ];then
    echo "Error executing script"
    exit 1
  fi
}
# Step1 > Create the patch
execute_script "create_patch.sh"

# Step 2 > Execute vmware.sh create
execute_script "./vwmare.sh create"

# Step 3 > Ask for the control plane IP 
read -p "Please enter the ip of the control plane (Lookup in vcenter):" control_plane_ip
# Execute basic IP validation
if [[ "$control_plane_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    IFS='.' read -r i1 i2 i3 i4 <<< "$control_plane_ip"
    if (( i1 >= 0 && i1 <= 255 )) && (( i2 >= 0 && i2 <= 255 )) && (( i3 >= 0 && i3 <= 255 )) && (( i4 >= 0 && i4 <= 255 )); then
        # Execute Talos commands
        talosctl --talosconfig talosconfig bootstrap -e "$control_plane_ip" -n "$control_plane_ip"
        talosctl --talosconfig talosconfig config endpoint "$control_plane_ip"
        talosctl --talosconfig talosconfig config node "$control_plane_ip"
        talosctl --talosconfig talosconfig kubeconfig .
        
        # Copy kubeconfig to user's home directory
        cp kubeconfig /home/$USER/.kube/config
        echo "Kubeconfig copied to /home/$USER/.kube/config"
    else
        echo "Invalid Control Plane IP address. Each octet must be between 0 and 255."
        exit 1
    fi
else
    echo "Invalid Control Plane IP address format. Please enter a valid IPv4 address."
    exit 1
fi
# Step 4 > Install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/refs/tags/v0.14.9/config/manifests/metallb-native.yaml
kubectl get namespaces && kubectl get pods -n metallb-system

# Step 5 > Create config map for metallb (the script will create the LB)
execute_script "./create_metallb.sh"
