# Talos Installation Instructions
I recomend you configure and install this on a jump host where you perform all your configurations from the ground up.

## Talos Installation Steps

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

5. **Note the Control Plane IP**  
   - After cluster creation, check in vCenter for one of the control plane IP addresses and note it down.

6. **Install `talosctl`**  
   - Follow the installation guide:  
     [Install talosctl](https://www.talos.dev/v1.9/talos-guides/install/talosctl/)

7. **Bootstrap Talos**  
   - Run the following command (replace the IP with the one you noted):  
     ```bash
     talosctl --talosconfig talosconfig bootstrap -e <YOUR_IP> -n <YOUR_IP>
     ```

8. **Configure Talos**  
   - Set the endpoint:  
     ```bash
     talosctl --talosconfig talosconfig config endpoint <YOUR_IP>
     ```  
   - Configure the node:  
     ```bash
     talosctl --talosconfig talosconfig config node <YOUR_IP>
     ```  
   - Get the kubeconfig:  
     ```bash
     talosctl --talosconfig talosconfig kubeconfig .
     ```

9. **Check Cluster Nodes**  
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
   - If it exists, delete it.

2. **Create Metallb Namespace & install**  
   - Run:  
     ```bash
     kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/refs/tags/v0.14.9/config/manifests/metallb-native.yaml
     ```

3. **Verify Installation**  
   - Check if the namespace and pods are created:  
     ```bash
     kubectl get namespaces && kubectl get pods -n metallb-system
     ```

4. **Create ConfigMap**  
   - Create a file named `metallb.yaml` with the following content:  
     ```yaml
     apiVersion: v1
     kind: ConfigMap
     metadata:
       namespace: metallb-system
       name: config
     data:
       config: |
         address-pools:
         - name: default
           protocol: layer2
           addresses:
           - 172.27.235.20-172.27.235.30
     ```  
   - Apply the config:  
     ```bash
     kubectl create -f metallb.yaml
     ```

6. **Deploy Nginx Container**  
   - Create a file named `nginx.yaml` with the following content:  
     ```yaml
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: nginx-deployment
       labels:
         app: nginx
     spec:
       replicas: 1
       selector:
         matchLabels:
           app: nginx
       template:
         metadata:
           labels:
             app: nginx
         spec:
           containers:
           - name: nginx
             image: nginx:latest
             ports:
             - containerPort: 80
     ---
     apiVersion: v1
     kind: Service
     metadata:
       name: nginx-service
     spec:
       selector:
         app: nginx
       ports:
         - protocol: TCP
           port: 80
           targetPort: 80
       type: LoadBalancer
     ```  
   - Deploy the Nginx service:  
     ```bash
     kubectl create -f nginx.yaml
     ```

7. **Check All Resources**  
   - Run:  
     ```bash
     kubectl get all
     ```  
   - You should see the pod and the LoadBalancer service with the external IP populated.

   When you no longer need the cluster you can tear it down by running ./vmware.sh destroy this will destroy the cluster and remove it from vcenter.
