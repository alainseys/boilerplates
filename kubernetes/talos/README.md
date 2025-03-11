# Talos
In my setup we use vcenter as the underlaying virtualisation envrioment because we want to host applications localy and if required we need to expose some ports to a LB.

## Tech stack used
- [Talos](https://www.siderolabs.com/platform/talos-os-for-kubernetes/)
- Vmware 8
- [Metallb](https://metallb.io/)
- [GOVC](https://github.com/vmware/govmomi/tree/main/govc)
- [K9S](https://k9scli.io/)

## Dependencies
- DHCP Server
- LB Scope exclusions