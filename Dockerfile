FROM scratch
ADD rootfs.tar /
ENTRYPOINT ["/bin/sh"]

