#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -y

PACKAGES="apt-transport-https ca-certificates lsb-release unattended-upgrades build-essential ripgrep ufw curl wget gnupg git zsh tmux fzf fd-find lsd vim-nox golang caddy tshark protobuf-compiler llvm clang libclang-dev libssl-dev libudev-dev"
apt install -y $PACKAGES

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
npm install -g pnpm

mkdir -p /etc/caddy
cat <<EOL > /etc/caddy/Caddyfile
explorer.zeropatience.net {
    reverse_proxy * localhost:5173
}
rpc.zeropatience.net {
    reverse_proxy * localhost:9945
}
EOL

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow https
ufw allow 30334
ufw --force enable

USERNAME=haiko

useradd -g users -G sudo -m -s /usr/bin/zsh ${USERNAME}
mkdir -m 0700 /home/${USERNAME}/.ssh
cp /root/.ssh/authorized_keys /home/${USERNAME}/.ssh
chown -R ${USERNAME}:users /home/${USERNAME}/.ssh
systemctl restart ssh
echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USERNAME}
sudo -u ${USERNAME} git clone https://github.com/${USERNAME}schol/dotfiles.git /home/${USERNAME}/dotfiles
sudo -u ${USERNAME} /home/${USERNAME}/dotfiles/mklinks.sh
sudo -u ${USERNAME} git clone https://github.com/haikoschol/polkadot-smoldot-webrtc-demo.git /home/${USERNAME}/polkadot-smoldot-webrtc-demo
sudo -u ${USERNAME} curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -u ${USERNAME} sh -s -- -y
sudo -u ${USERNAME} /home/${USERNAME}/.cargo/bin/rustup target add wasm32v1-none wasm32-unknown-unknown
