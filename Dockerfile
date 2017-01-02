FROM ioft/armhf-ubuntu:xenial

COPY qemu-arm /usr/bin/qemu-arm-static

RUN apt-get update

RUN apt-get install -y curl python && \
	curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# RUN apt-get install -y python-apt && \
#	pip install pybombs
 RUN apt-get install -y python-apt git sudo && \
	pip install git+https://github.com/amboar/pybombs.git

RUN pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git && \
	pybombs recipes add gr-etcetera git+https://github.com/amboar/gr-etcetera.git

RUN mkdir -p ${HOME}/gnuradio/flex2sms && \
	pybombs prefix init ${HOME}/gnuradio/flex2sms -a flex2sms

RUN yes | pybombs -p flex2sms install gr-pager
