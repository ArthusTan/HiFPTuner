# Base Image
FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# Set the working directory to /root
WORKDIR /root


RUN sudo apt-get -y update
RUN apt-get install -y wget && \
	rm -rf /var/lib/apt/lists/*
RUN sudo apt-get -y update
RUN apt-get install dialog apt-utils -y
RUN sudo apt-get install build-essential -y
RUN sudo apt-get install git -y
RUN sudo apt-get install python -y
RUN sudo apt-get install vim -y
RUN sudo apt-get install software-properties-common -y
RUN sudo add-apt-repository universe

# update gcc
RUN sudo apt-get install gcc
# RUN \
# 	sudo apt-get install python-software-properties -y && \
# 	sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
# 	sudo apt-get update -y && \
# 	sudo apt-get install gcc-4.8 -y && \
# 	sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50

# update g++
RUN \
	sudo apt-get install g++-4.8 && \
	sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50

# installing emacs
RUN sudo apt-get -y install emacs23

# Downloading llvm 3.0 and 3.8 binaries
RUN \
	cd $HOME && \
	wget http://llvm.org/releases/3.0/clang+llvm-3.0-x86_64-linux-Ubuntu-11_10.tar.gz && \
	tar -xzvf clang+llvm-3.0-x86_64-linux-Ubuntu-11_10.tar.gz && \
	mv clang+llvm-3.0-x86_64-linux-Ubuntu-11_10 llvm-3.0 && \
	rm -f clang+llvm-3.0-x86_64-linux-Ubuntu-11_10.tar.gz
RUN \
	wget http://releases.llvm.org/3.8.0/clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz && \
	tar -xvf clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz && \
	mv clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04 llvm-3.8 && \
	rm -f clang+llvm-3.8.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz

# Updating .bashrc file to configure llvm
RUN \
	echo "export LLVM_VERSION=llvm-3.0" >> ~/.bashrc && \
	echo "export PATH=$HOME/\$LLVM_VERSION/bin:$PATH" >> ~/.bashrc && \
	echo "export LD_LIBRARY_PATH=$HOME/\$LLVM_VERSION/lib:$LD_LIBRARY_PATH" >> ~/.bashrc && \
    echo "export CPATH=$HOME/\$LLVM_VERSION/include:." >> ~/.bashrc && \
	echo "export LLVM_COMPILER=clang" >> ~/.bashrc

RUN /bin/bash -c "source ~/.bashrc"

ENV LLVM_VERSION=llvm-3.0
ENV	PATH="/root/$LLVM_VERSION/bin:${PATH}"
ENV LD_LIBRARY_PATH="/root/$LLVM_VERSION/lib:${LD_LIBRARY_PATH}"
ENV LLVM_COMPILER=clang
ENV CORVETTE_PATH="/root/precimonious"

# Installing scons
RUN \
	cd && \
	wget -qnc http://prdownloads.sourceforge.net/scons/scons-2.4.0.tar.gz && \
	tar xzvf scons-2.4.0.tar.gz && \
	rm -f scons-2.4.0.tar.gz && \
	mv scons-2.4.0 scons && \
	cd scons && \
	sudo python2.7 setup.py install

# Cloning Precimonious 
RUN \
	cd && \
	git clone https://github.com/ucd-plse/precimonious.git && \
	cd precimonious && \
	echo "export CORVETTE_PATH=$HOME/precimonious" >> ~/.bashrc && \
	#echo "export PATH=$HOME/llvm-3.0/bin:$PATH" >> ~/.bashrc && \
	/bin/bash -c "source ~/.bashrc" && \
	cd src && \
	sed -i "s/SHLINKFLAGS='-Wl',/SHLINKFLAGS='',/g" SConscript && \
	sed -i "s/LIBS='LLVM-\$llvm_version'/#LIBS='LLVM-\$llvm_version'/g" SConscript && \
    echo $PATH && \
	#printenv
	scons -U && \
	scons -U test


# Copy the current directory contents into the container at /root/precimonious
#COPY exercise-1/ /root/precimonious/exercise-1/
#COPY exercise-2/ /root/precimonious/exercise-2/
#COPY README /root 


# Installing NetworkX, community, and graph python packages
RUN \
    sudo apt-get install -y python-dev libgraphviz-dev python-matplotlib && \
    sudo apt-get install -y python-pip && \
    pip install 'networkx==2.2' && \
    pip install python-louvain && \
    pip install graphviz && \
    pip install pygraphviz && \
    sudo apt-get install -y bc

# Cloning and Installing HiFPTuner
RUN \
	echo "export HIFPTUNER_PATH=$HOME/HiFPTuner" >> ~/.bashrc && \
	echo "export HIFP_PRECI=$HOME/HiFPTuner/precimonious" >> ~/.bashrc && \
	echo "export LD_LIBRARY_PATH=$HOME/\$HIFP_PRECI/logging:$LD_LIBRARY_PATH" >> ~/.bashrc && \
	echo "export LIBRARY_PATH=$HOME/\$HIFP_PRECI/logging" >> ~/.bashrc


# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME Precimonious

# Run app.py when the container launches
#RUN echo 'all set, rock on!'	