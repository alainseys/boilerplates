# AWX Installation Guide

Hello i am running now my awx instance on 1 vm this was good for a very long time (+2years) now we are starting to feel some lag on the network due to the many git pull from differtent repositories.
So it was time to take a look at kubernets, oh boy was i in for a ride :) 

The current enviroment:
- Vcenter host
- Gitlab
- Packer

For the base os i have started with Ubuntu.
Since we have vcenter as infrasturure on prem we encounterd the problem that kubernetes is not giving ip adress out so we needed something that is able to give use some ip ranges.
SO i have used this repo that automates the installation of metallb on ubuntu systems and takes care of installation of Kubernetes: https://github.com/alainseys/k3s-ansible

## Prerequisites

- **Kubernetes Cluster**: Ensure you have a running Kubernetes cluster.
- **MetalLB**: Installed and configured in the cluster.
- **NFS Volume**: Set up with appropriate permissions for the cluster.
- **NFS Mounted Volume**: Ensure it's mounted to your developer box (remember to disconnect it after use).

## Installation Steps

1. **Mount NFS**: Ensure your NFS is mounted.
  
2. **Create Required Directories**:
   ```bash
   mkdir -p /mnt/NFS-SERVER/postgres-15
   mkdir -p /mnt/NFS-SERVER/projects
   ```
3. **Change Permissions**:
    ```bash
    sudo chown 1000:0 /mnt/NFS-SERVER/projects
    ```
4. **Navigate and checkout verion**:
    ```bash
        cd awx-on-k3s
        git checkout 2.19.1
        kubectl apply -k operator
    ```
5. **Configuration Host**:
    ```bash
        export AWX_HOST="awx.yourdomain.com"
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out ./base/tls.crt -keyout ./base/tls.key -subj "/CN=${AWX_HOST}/O=${AWX_HOST}" -addext "subjectAltName = DNS:${AWX_HOST}"
    ```
6. **Copy configuration files**:
    Copy 
    - awx.yaml
    - kustomization.yaml
    - pv.yaml (example of NFS storage included)
    - pvc.yaml
7. **Deployment**:
    ```shell
        kubectl apply -k base
    ```
    Now the only thing to do is wait for ansible to finish to install awx.
8. **Monitor Logs**:
    ```shell
       kubectl -n awx logs -f deployments/awx-operator-controller-manager
    ```
9. **Wrap up**:
    This output will show you all of the resources and the ip of your instance where you can connect to , if evrything went good you should be able to logon to the External IP.
    ```shell
        kubectl -n awx get awx,all,ingress,secrets
    ```

## Manual steps
The only thing to do is now configure awx and your dns to point to your VIP.
