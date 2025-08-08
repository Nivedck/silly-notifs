#!/usr/bin/env sh

set -e  # Exit immediately if a command fails

cargo build --release

sudo mv target/release/governor-control /usr/local/bin/
sudo chown root:root /usr/local/bin/governor-control
sudo chmod 4755 /usr/local/bin/governor-control

echo "✅ set-governor installed to /usr/local/bin with setuid root."
