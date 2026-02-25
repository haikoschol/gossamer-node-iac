# Polkadot/Smoldot WebRTC Demo on Hetzner Cloud

This repo contains [OpenTofu](https://opentofu.org/) configuration and a cloud-init script for setting up a server on [Hetzner Cloud](https://www.hetzner.com/cloud/) for running a [Polkadot/Smoldot WebRTC Demo](https://github.com/haikoschol/polkadot-smoldot-webrtc-demo) node.

In order to use this, you need a Hetzner account, generate an API token for the Cloud API on https://console.hetzner.cloud and one for the DNS API on https://dns.hetzner.com/.

You probably also want to change a few things in [cloud-init.sh](./cloud-init.sh) related to the user account, dotfile stuff and the hostname in the Caddyfile.

If you don't use ssh-agent, you probably also want to change that part in [main.tf](./main.tf) to read the public key from `~/.ssh/id_rsa.pub` or whatever the filename is.

After running `tofu apply` successfully, ssh into the box and run the following in `~/polkadot-smoldot-webrtc-demo`

* `./demo.py --init-only`
* Follow instructions in `~/polkadot-smoldot-webrtc-demo/README.md` for manual demo, leaving out the Chrome part
