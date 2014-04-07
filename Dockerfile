FROM ubuntu:saucy

# install required packages
RUN apt-get update
RUN apt-get -y install python-software-properties apt-utils vim htop dpkg-dev \
  openssh-server git-core wget software-properties-common
RUN apt-add-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse"
RUN apt-get update

RUN apt-get install -y faac yasm

# create the ubuntu user
RUN addgroup --system ubuntu
RUN adduser --system --shell /bin/bash --gecos 'ubuntu' \
  --uid 1000 --disabled-password --home /home/ubuntu ubuntu
RUN adduser ubuntu sudo
RUN echo ubuntu:ubuntu | chpasswd
RUN echo "ubuntu ALL=NOPASSWD:ALL" >> /etc/sudoers
USER ubuntu
ENV HOME /home/ubuntu
WORKDIR /home/ubuntu

# Git config is needed so that cerbero can cleanly fetch some git repos
RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

# build gstreamer 1.0 from cerbero source
# the build commands are split so that docker can resume in case of errors
RUN git clone --depth 1 git://anongit.freedesktop.org/gstreamer/cerbero
# hack: to pass "-y" argument to apt-get install launched by "cerbero bootstrap"
RUN sed -i 's/apt-get install/apt-get install -y/g' cerbero/cerbero/bootstrap/linux.py
RUN cd cerbero; ./cerbero-uninstalled bootstrap

RUN cd cerbero; ./cerbero-uninstalled build \
  glib bison gstreamer-1.0

RUN cd cerbero; ./cerbero-uninstalled build \
  py2cairo pygobject gst-plugins-base-1.0 gst-plugins-good-1.0 

RUN cd cerbero; ./cerbero-uninstalled build \
  gst-plugins-bad-1.0 gst-plugins-ugly-1.0

RUN cd cerbero; ./cerbero-uninstalled build \
  gst-libav-1.0
