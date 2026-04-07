#!/bin/bash
set -euo pipefail

GUIX_VERSION="1.5.0"

current_guix="/var/guix/profiles/per-user/root/current-guix"

sys_create_store() {
    echo "Fetching and verifying tarball..."
    tarball="guix-binary-${GUIX_VERSION}.$(uname -m)-linux.tar.xz"

    tmp_dir="$(mktemp -d -p /tmp guix.XXX)"
    cd "$tmp_dir" || exit

    sig_url="https://ftpmirror.gnu.org/gnu/guix/${tarball}.sig"
    bin_url="https://ftpmirror.gnu.org/gnu/guix/${tarball}"

    wget "${sig_url}"
    wget "${bin_url}"

    for key in /usr/lib/pki/guix-gpg/*.pub; do
	    gpg --import "$key"
    done

    if ! gpg --verify "${tarball}.sig" "${tarball}"; then
        echo "ERROR: PGP verification failed! The tarball may be compromised."
        exit 1
    fi
    echo "PGP verification successful."

    tar --extract --strip-components=1 --file "${tmp_dir}/${tarball}" \
        --owner=guix-daemon --group=guix-daemon -C /

    chown -R guix-daemon:guix-daemon /gnu /var/guix
    chown -Rh root:root /var/guix/profiles/per-user/root

    mkdir -p ~root/.config/guix
    ln -sf /var/guix/profiles/per-user/root/current-guix \
        ~root/.config/guix/current
    GUIX_PROFILE=~root/.config/guix/current

    # shellcheck source=/dev/null
    . "${GUIX_PROFILE}/etc/profile"
}

sys_setup_selinux() {

    restorecon -R /var/guix
    restorecon -R /gnu
}

sys_create_mount_units() {

    # Ensure persistent directories exist and are owned by 'guix-daemon'
    mkdir -p /var/lib/gnu /var/guix/daemon-socket /var/log/guix
    chown -R guix-daemon:guix-daemon \
        /var/lib/gnu /var/guix /var/log/guix
    chmod 755 /var/log/guix

    systemctl enable --now gnu.mount
}

sys_start_guix_daemon() {

    systemctl daemon-reload
    systemctl enable --now guix-daemon.service

}

sys_authorize_build_farms() {
    echo "Authorizing official Guix build farms..."

    # Ensure the config directory exists before trying to authorize
    mkdir -p /etc/guix

    share_guix="${current_guix}/share/guix"
    if [ -d "${share_guix}" ]; then
        guix archive --authorize <"${share_guix}/ci.guix.gnu.org.pub"
        guix archive --authorize <"${share_guix}/bordeaux.guix.gnu.org.pub"
        echo "Build farm keys authorized successfully."
    else
        echo "Warning: Could not find build farm keys in ${share_guix}"
    fi
}

sys_create_shell_completion() {

    # Fish completions: Use /etc/fish/completions for Silverblue persistence
    echo "Linking Fish completions to /etc/fish/completions..."
    mkdir -p /etc/fish/completions
    ln -sf "${current_guix}/share/fish/vendor_completions.d/guix.fish" /etc/fish/completions/guix.fish

    # Bash completions: Use /etc/bash_completion.d as a standard fallback
    echo "Linking Bash completions to /etc/bash_completion.d..."
    mkdir -p /etc/bash_completion.d
    ln -sf "${current_guix}/etc/bash_completion.d/guix-daemon" /etc/bash_completion.d/guix-daemon
    ln -sf "${current_guix}/etc/bash_completion.d/guix" /etc/bash_completion.d/guix
}

sys_create_namespace() {
    kvmgid="$(getent group kvm | cut -f3 -d:)"
    if ! grep -q guix-daemon /etc/subgid; then
        echo "guix-daemon:$kvmgid:1" >>/etc/subgid
    fi
}

fcos_guix_install() {

    sys_create_namespace

    sys_create_mount_units

    sys_create_store

    sys_setup_selinux

    sys_start_guix_daemon

    sys_authorize_build_farms

    sys_create_shell_completion

}

fcos_guix_install && cat <<'EOF'

Installation complete. To finalize your shell, add the following to your config:

export GUIX_PROFILE="$HOME/.config/guix/current"
source "$GUIX_PROFILE/etc/profile"

EOF

# https://codeberg.org/16levels/guix-silverblue/src/branch/main/sysroot/usr/bin/guix-init.sh