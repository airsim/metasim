#
# Dockerfile: http://github.com/airsim/metasim/tree/master/docker/macos/Dockerfile
# Docker Hub/Cloud page: https://cloud.docker.com/u/infrahelpers/repository/docker/infrahelpers/tvlsim
# Usual Docker tag: infrahelpers/tvlsim:macos
#
# Umbrella project for the Travel Market Simulator (TvlSim / AirSim)
#
# Base image: MacOS Monterey (12.6)
# * Docker Hub: https://hub.docker.com/r/sickcodes/docker-osx
# * Dockerfile: https://github.com/sickcodes/Docker-OSX/blob/master/Dockerfile.monterey
# * Docker tag: sickcodes/docker-osx:monterey
#
FROM sickcodes/docker-osx:monterey

LABEL authors="Denis Arnaud <denis.arnaud_github at m4x dot org>"

# Docker build time environment variables
ENV container docker
ENV HOME /home/arch/OSX-KVM
ENV SIM_DIR $HOME/dev/sim

#
ADD resources/bashrc $HOME/.bashrc

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN source $HOME/.bashrc && \
	brew install openssl@1.1 xz && \
	brew install boost boost-python3 cmake libedit && \
    brew install xapian sqlite mysql mysql-client && \
    brew install icu4c protobuf protobuf-c doxygen && \
    brew install homebrew/portable-ruby/portable-readline && \
    brew install cppzmq czmq zeromq

# SOCI
RUN source $HOME/.bashrc && \
    git clone https://github.com/SOCI/soci.git socigit && \
    mkdir -p socigit/build/head && \
    cd socigit/build/head && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_BUILD_TYPE=Debug -DSOCI_CXX11=ON \
    -DSOCI_ASAN=ON -DCMAKE_VERBOSE_MAKEFILE=OFF \
    -DSOCI_TESTS=OFF -DSOCI_STATIC=OFF -DSOCI_DB2=OFF -DSOCI_EMPTY=ON \
    -DSOCI_FIREBIRD=OFF -DSOCI_MYSQL=ON -DSOCI_ODBC=OFF -DSOCI_ORACLE=OFF \
    -DSOCI_POSTGRESQL=ON -DSOCI_SQLITE3=ON ../.. && \
    make && sudo make install && \
    cd $HOME

# Ruby and Rake
RUN source $HOME/.bashrc && \
	brew install rbenv ruby-build ruby
RUN	source $HOME/.bashrc && \
	sudo gem install rake nokogiri

# Prepare the build environment
RUN mkdir -p $SIM_DIR
WORKDIR $SIM_DIR

ADD resources/Rakefile resources/metasim.yaml.sample $SIM_DIR/
RUN mv $SIM_DIR/metasim.yaml.sample $SIM_DIR/metasim.yaml

# Build and deliver all the components
RUN rake checkout
RUN rake offline=true configure
RUN rake offline=true install
RUN rake offline=true dist

# Entry point
CMD ["/bin/bash"]

