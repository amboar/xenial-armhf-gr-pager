FROM ubuntu:xenial

RUN apt-get update

RUN apt-get install -y build-essential \
	    chrpath \
	    diffstat \
	    gawk \
	    git \
	    libncurses5-dev \
	    pkg-config \
	    subversion \
	    texi2html \
	    texinfo \
	    python2.7 \
	    python3 \
	    wget \
	    cpio

RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# Make sure we can `source`
RUN rm /bin/sh && ln -sf /bin/bash /bin/sh

# Hack - 149 corresponds to en_US.UTF-8
RUN apt-get install -y locales && \
	echo 149 | dpkg-reconfigure locales

RUN adduser --shell /bin/bash rpi

USER rpi

RUN cd /home/rpi && \
	git clone --depth 1 -b morty git://git.yoctoproject.org/poky.git poky-morty && \
	git clone --depth 1 -b morty git://git.openembedded.org/meta-openembedded poky-morty/meta-openembedded && \
	git clone --depth 1 -b morty https://github.com/meta-qt5/meta-qt5.git poky-morty/meta-qt5 && \
	git clone --depth 1 -b master git://git.yoctoproject.org/meta-raspberrypi poky-morty/meta-raspberrypi

RUN mkdir /home/rpi/rpi && \
	cd /home/rpi/rpi && \
	git clone --depth 1 -b morty git://github.com/jumpnow/meta-rpi

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN cd /home/rpi/rpi && \
	TEMPLATECONF=/home/rpi/rpi/meta-rpi/conf source /home/rpi/poky-morty/oe-init-build-env && \
	bitbake console-image -c populate_sdk_ext && \
	mkdir /home/rpi/rpi/sdk && \
	cp -a tmp/deploy/sdk/* /home/rpi/rpi/sdk && \
	cd /home/rpi && \
	rm -rf /home/rpi/rpi/build

