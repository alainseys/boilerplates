# Talos Installation Instructions
This are the manual installation instruction i am working on some scripts to automate the process.

Tech stack
- Vmware
- Govc
- Talos os
- Kubernetes
- Metallb

## Installation Steps
1. **Install `govc`**  
   - [Install govc](https://github.com/vmware/govmomi/blob/main/govc/README.md)

2. **Run the Patch Creation Script**  
   - Execute the script in this repo:  
     ```bash
     ./create_patch.sh
     ```  
   - This will prompt for the VIP IP and create `cp.patch.yaml`.

3. **Upload OVA to vCenter**  
   - Run the VMware script with the following command:  
     ```bash
     ./vmware.sh upload_ova
     ```
4. **Create the Cluster**  
   - Execute the command:  
     ```bash
     ./vmware.sh create
     ```
5. **Install `talosctl`**  
   - Follow the installation guide:  
     [Install talosctl](https://www.talos.dev/v1.9/talos-guides/install/talosctl/)

6. **Exectue talos_post.sh**  
   - Execute the command:  
     ```bash
     ./talos_post.sh
     ```
     This will prompt you to enter the control plane ip based on the input the will bootstrap the system.

7. **Check Cluster Nodes**  
   - Run the following command to see the cluster nodes:  
     ```bash
     kubectl --kubeconfig=kubeconfig get nodes
     ```

## Metallb Configuration
1. **Verify Metallb Namespace**
   - Check for existing namespaces:  
     ```bash
     kubectl get namespaces
     ```  
   If it exists, delete it.

2. **Install the manifest**
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
    ```
3. **Define the address pool**
    (see sample [config)](ipaddresses.yml)
    ```yaml
    apiVersion: metallb.io/v1beta1 
    kind: IPAddressPool 
    metadata: 
        name: first-pool 
        namespace: metallb-system 
    spec: 
        addresses: 
        - 10.1.149.240-10.1.149.250
    ```
4. **Define the layer2 adviserment**
    (see sample [config](layer2.yaml))
    ```yaml
    apiVersion: metallb.io/v1beta1 
    kind: L2Advertisement 
    metadata: 
        name: first-pool 
        namespace: metallb-system
    ```
5. **Apply the config**

    ```shell kubeclt create -f ipaddresses.yaml ```

    ```shell kubeclt create -f layer2.yaml ```

6. **Verify**
    
    To verify you can run the following command:
    ```shell kubectl get ipaddresspools.metallb.io -A```

    This command should output the specefied range.

7. **Test**
    
    To test the application we will create a simple nginx application and expose port 80

    ```shell 
    kubectl create deploy nginx --image nginx:latest

    kubectl expose deploy nginx --port 80 --type LoadBalancer

    kubectl get service | grep nginx (you wil now see a external ip)
    ```


