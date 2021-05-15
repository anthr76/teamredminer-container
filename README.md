# teamredminer-container

Arch linux base container with amdgpu proprietary drivers, and TeamRedMiner installed to mine as a rootless user. More docs, and proper tagging to follow.

Example usage:

```sh
podman run --rm -it --userns keep-id --privileged --volume /dev/dri:/dev/dri:rslave ghcr.io/anthr76/teamred-miner -a ethash -o stratum+tcp://us1.ethermine.org:4444 -u 0x6e4b81F4f884dD394501be65e5af3265950D3692 --eth_4g_max_alloc=4078 --eth_config=B
```