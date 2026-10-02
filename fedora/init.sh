#!/usr/bin/env bash
set -eu

BASHRC="$HOME/.bashrc"

# Import Microsoft GPG key and add Visual Studio Code and Edge repository
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
echo -e "[microsoft-edge]\nname=Microsoft Edge\nbaseurl=https://packages.microsoft.com/yumrepos/edge-stable\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/microsoft-edge.repo > /dev/null

# Replace Fedora repository URLs with Tsinghua University mirrors
sed -e 's|^metalink=|#metalink=|g' \
    -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora|g' \
    -i.bak \
    /etc/yum.repos.d/fedora.repo \
    /etc/yum.repos.d/fedora-updates.repo

sudo dnf clean all && sudo dnf makecache && sudo dnf -y update

if grep -q 'prepend_PATH' "$BASHRC"; then
    echo "prepend_PATH function is already defined in .bashrc. Skipping definition."
else
    echo "Defining prepend_PATH function in .bashrc..."
    cat >> "$BASHRC" <<'EOF'

prepend_PATH() {
    local dir="$1"

    [[ -z "$dir" ]] && return 1

    if [[ ":${PATH}:" == *":${dir}:"* ]];then
        return 0
    fi

    PATH="${dir}:${PATH}"
}

EOF
fi

bash ./rust-init.sh &
