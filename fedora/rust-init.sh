#!/usr/bin/env bash
set -eu

BASHRC="$HOME/.bashrc"

if grep -q 'RUSTUP_DIST_SERVER' "$BASHRC"; then
    echo "Rustup is already installed. Skipping installation."
else
    echo "Installing Rustup..."
    cat >> "$BASHRC" <<'EOF'

# Rust Proxy configuration
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

EOF
    export RUSTUP_DIST_SERVER="https://rsproxy.cn"
    export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y
    mkdir -p "$HOME/.cargo"
    cat >> "$HOME/.cargo/config.toml" <<'EOF'

[source.crates-io]
replace-with = 'rsproxy-sparse'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true

[target.'cfg(target_os = "linux")']
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=mold"]

EOF
fi