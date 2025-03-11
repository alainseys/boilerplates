# Talos Setup

In this setup, we utilize vCenter as the underlying virtualization environment to host applications locally. If required, we can expose certain ports to a Load Balancer (LB).

For detailed installation steps, refer to the [installation guide](install.md).

## Tech Stack Used

- [Talos](https://www.siderolabs.com/platform/talos-os-for-kubernetes/)
- VMware 8
- [MetalLB](https://metallb.io/)
- [GOVC](https://github.com/vmware/govmomi/tree/main/govc)
- [K9S](https://k9scli.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Dependencies

- DHCP Server
- Load Balancer (LB) Scope Exclusions