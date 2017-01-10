FROM ubuntu:xenial

# Derived from http://www.jumpnowtek.com/rpi/Raspberry-Pi-Systems-with-Yocto.html

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

# Derived from http://gnuradio.org/redmine/projects/gnuradio/wiki/OE_PyBOMBS

USER root

RUN apt-get install -y curl python && \
        curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN apt-get install -y python-apt git sudo

RUN pip install git+https://github.com/amboar/pybombs.git

RUN mv /usr/local/lib/python2.7/dist-packages/pybombs/templates/cmake.lwt /usr/local/lib/python2.7/dist-packages/pybombs/templates/cmake-native.lwt
COPY oe-cmake.lwt /usr/local/lib/python2.7/dist-packages/pybombs/templates/cmake.lwt

USER rpi

RUN mkdir /home/rpi/pybombs

RUN cd /home/rpi && \
	git clone https://github.com/gnuradio/gnuradio.git

RUN mkdir /home/rpi/pybombs/oecore-pkg && \
	cp /home/rpi/rpi/sdk/poky-glibc-x86_64-console-image-cortexa7hf-neon-vfpv4-toolchain-ext-2.2.sh /home/rpi/pybombs/oecore-pkg/ && \
	cp /home/rpi/gnuradio/cmake/Toolchains/oe-sdk_cross.cmake /home/rpi/pybombs/oecore-pkg/cross.cmake && \
	cd /home/rpi/pybombs/oecore-pkg && \
	ln -s poky-glibc-x86_64-console-image-cortexa7hf-neon-vfpv4-toolchain-ext-2.2.sh oecore.sh && \
	tar -czpvf ../oecore-pkg.tar.gz .

RUN mkdir /home/rpi/pybombs/oecore-cross
COPY oe-sdk.lwr /home/rpi/pybombs/oecore-cross

RUN pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git && \
        pybombs recipes add gr-etcetera git+https://github.com/amboar/gr-etcetera.git && \
	pybombs recipes add oecore-cross /home/rpi/pybombs/oecore-cross

RUN pybombs prefix init /home/rpi/pybombs/rpi

RUN pybombs install oe-sdk

RUN pybombs install gnuradio
