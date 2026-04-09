#!/bin/fish

echo "This will let guix-daemon do whatever it wants, this might be favorable to do if selinux breaks but will significantly mess up the security of the system"
echo "Do you want to continue?"
if ! gum confirm
    exit 0
end
run0 bash -c "semanage permissive -a guix_daemon.guix_daemon_t"