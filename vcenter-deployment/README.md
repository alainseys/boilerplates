# Kubernetes on vcenter using talos

Download & install govc
```shell curl -L -o - "https://github.com/vmware/govmomi/releases/latest/download/govc_$(uname -s)_$(uname -m).tar.gz" | sudo tar -C /usr/local/bin -xvzf - govc ```

Download & install talosctl
```shell curl -sL https://talos.dev/install | sh ```

### Choosing a vip
Choose a dedicated vip in this example i will use 172.27.235.20 this is vip is required to LB.

Download the cp.patch
```shell curl -fsSLO https://raw.githubusercontent.com/siderolabs/talos/master/website/content/v1.7/talos-guides/install/virtualized-platforms/vmware/cp.patch.yaml ```
