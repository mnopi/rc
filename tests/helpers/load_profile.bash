# shellcheck shell=bash
. "$(dirname "${BASH_SOURCE[0]}")/../../rc/profile"
. bats.bash
IMAGES="$(cat <<EOF
alpine
archlinux
bash
busybox
centos
debian
fedora
nixos
python3.10:alpine
python3.10:bullseye
python3.10:slim
ubuntu
EOF
)"
