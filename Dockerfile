FROM ubuntu:trusty

MAINTAINER Samuel Cozannet <samuel.cozannet@madeden.com>

ENV MODEL_NEURALTALK "https://s3.amazonaws.com/rossgoodwin/models/2016-01-12_neuraltalk2_model_01_rg.t7"
ENV MODEL_CHARNN "https://s3.amazonaws.com/rossgoodwin/models/2016-01-12_char-rnn_model_01_rg.t7"
ENV FIREBASE_CREDENTIAL "config/blazing-heat-1438-firebase-adminsdk-h3irc-12eaf69af0.json"

RUN apt-get update 
RUN sudo apt-get -y install \
        git \
        build-essential \
        cmake \
        wget \
        curl \
        libatlas-base-dev \
        gfortran \
        software-properties-common \
        python-software-properties \
        python-numpy

RUN apt-get upgrade -yqq && \
    apt-get install -yqq nano curl git wget libprotobuf-dev protobuf-compiler libhdf5-serial-dev hdf5-tools python-pip build-essential python-dev && \
    mkdir -p /opt/neural-networks

# Install torch
RUN cd /opt/neural-networks && \
    wget https://raw.githubusercontent.com/torch/ezinstall/master/install-deps && \
    chmod +x ./install-deps && \
    ./install-deps && \
    git clone https://github.com/torch/distro.git /opt/neural-networks/torch --recursive && \
    cd /opt/neural-networks/torch && \
    ./install.sh -b 

# ENV PATH="/opt/neural-networks/torch/install/bin:${PATH}"
RUN /bin/bash -c "source ~/.bashrc"

# Install additional dependencies
RUN cd /opt/neural-networks/torch && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    luarocks install nn && \
    luarocks install nngraph && \
    luarocks install image && \
    luarocks install loadcaffe && \
    luarocks install optim

# Install HDF5 tools
RUN cd /opt/neural-networks && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    git clone https://github.com/deepmind/torch-hdf5.git && \
    cd torch-hdf5 && \
    luarocks make hdf5-0-0.rockspec LIBHDF5_LIBDIR="/usr/lib/x86_64-linux-gnu/"

# Install h5py
RUN pip install --upgrade cython && \
    pip install --upgrade numpy && \
    pip install --upgrade h5py 

# Install cjson
RUN cd /opt/neural-networks/ && \
    . /opt/neural-networks/torch/install/bin/torch-activate && \
    wget -c http://www.kyne.com.au/%7Emark/software/download/lua-cjson-2.1.0.tar.gz && \
    tar xfz lua-cjson-2.1.0.tar.gz && \
    cd lua-cjson-2.1.0 && \
    luarocks make

# Install flask
RUN pip install flask-restful && \
    pip install Flask-HTTPAuth

# Download and set up service
RUN cd /opt/neural-networks && \
    cd /opt/neural-networks && \
    cd /opt/neural-networks && \ 
    cd /opt/neural-networks && \
    cd /opt/neural-networks && \
    git clone "https://github.com/archzzz/mysteriousObjectsAtNoon.git" && \
    cd /opt/neural-networks/mysteriousObjectsAtNoon/lib && \
    git clone "https://github.com/archzzz/neuraltalk2.git" && \
    git clone "https://github.com/karpathy/char-rnn.git" && \
    cd /opt/neural-networks/mysteriousObjectsAtNoon/neuralsnap/models && \
    wget $MODEL_NEURALTALK && \
    wget $MODEL_CHARNN

RUN pip install firebase-admin
ADD FIREBASE_CREDENTIAL /opt/neural-networks/firebase-key.json

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# VOLUME /data

# Expose default port
expose 5000


CMD [ "python", "-u", "/opt/neural-networks/mysteriousObjectsAtNoon/brittanyService.py"]