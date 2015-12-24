#!/usr/bin/env bash
set -e

mkimg="$(basename "$0")"

busybox=busybox

dir="$(mktemp -d ${TMPDIR:-/tmp}/docker-mkimage.XXXXXXXXXX)"

# Docker mounts tmpfs at /dev and procfs at /proc so we can remove them
rm -rf $dir/dev $dir/proc
mkdir -p $dir/{dev,proc,bin,etc}

ls -la $dir
# make sure /etc/resolv.conf has something useful in it
cat > $dir/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

rm -f "$dir/bin/busybox" # just in case
cp "$busybox" "$dir/bin/busybox"
chmod +x  "$dir/bin/busybox"

(
        cd "$dir"

        IFS=$'\n'
        modules=( $(bin/busybox --list-modules) )
        unset IFS

        for module in "${modules[@]}"; do
                mkdir -p "$(dirname "$module")"
                ln -sf /bin/busybox "$module"
        done
	cd -
)


tarFile="rootfs.tar"
(
	set -x
	tar --numeric-owner --create --auto-compress --file "$tarFile" --directory "$dir" --transform='s,^./,,' .
)
