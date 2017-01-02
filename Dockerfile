FROM ubuntu:yakkety
RUN apt-get update && apt-get install -y debootstrap qemu-user-static libc6-dev-armhf-cross proot
RUN qemu-debootstrap --arch armhf --keep-debootstrap-dir yakkety root http://ports.ubuntu.com/
RUN apt-get build-dep qemu-user-static && \
	git clone https://github.com/qemu/qemu && \
	cd qemu && \
	./configure --target-list=arm-linux-user --static --prefix=/usr/local && \
	make -j$(nproc) && \
	make install
