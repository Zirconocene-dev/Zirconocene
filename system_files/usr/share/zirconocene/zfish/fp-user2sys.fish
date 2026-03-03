#!/bin/env fish

function read_confirm
  while true
    read -l -P '[y/N] ' confirm
    switch (echo $confirm | cut -c 1)
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

echo Do you want to transfer only apps?
if read_confirm
    set -ag _options "--app"
else
    set -ag _options "--all"
end 

if test -z $XDG_DATA_HOME # determine size taken by user flatpak install 
    set user_size (du -s $HOME/.local/share/flatpak | grep -o '^[0-9]*')
else 
    set user_size (du -s $XDG_DATA_HOME/flatpak | grep -o '^[0-9]*')
end

if test -z $XDG_CACHE_HOME # cache where to save the temporary flatpak "USB"
    set cache_location $HOME/.cache/fp-user2sys
else 
    set cache_location $XDG_CACHE_HOME/fp-user2sys
end
mkdir -p "$cache_location"

set space_available (df -k --output=avail /var/lib/flatpak/ | sed "/Avail/d")

set size_left (math $space_available - $user_size \* 1.75)
if test $size_left -lt 0
    echo The size left is less than flatpak install\'s 1>&2
    echo Please create more space and rerun this script 1>&2
    exit 2 
end

set app_list (flatpak list $_options --user --columns=ref,origin | grep flathub | grep -v flathub-beta | sed 's/flathub$//;s/\s//g')

# for i in $first_app_list
#     set -a app_list (echo $i | sed "s/\s//g")
# end

echo Everything seems right, type Y\(es\) to continue
if ! read_confirm
    exit 0
end

flatpak remote-modify --user --collection-id=org.flathub.Stable flathub
flatpak remote-modify --system --collection-id=org.flathub.Stable flathub

for i in $app_list
    flatpak create-usb "$cache_location" --allow-partial $i
    if test ! "$status" -eq 0
        echo ERROR: Something failed, please figure out what\'s causing this and rerun! 1>&2
        rm -rf "$cache_location"
        exit 3
    end
end

echo INFO: Installing... 1>&2
for i in $app_list
    flatpak install -y --system --sideload-repo=$cache_location/.ostree/repo $i
end
echo finished installing apps!!!
echo Uninstall apps from user?
if read_confirm
    for i in $app_list
        flatpak uninstall -y --user $i
    end
end
echo Finished successfully!!
rm -rf "$cache_location"