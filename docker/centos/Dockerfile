#
# http://github.com/airsim/metasim/tree/master/docker/centos
# Umbrella project for the Travel Market Simulator (TvlSim / AirSim)
#
FROM infrahelpers/cpppython:centos8
MAINTAINER Denis Arnaud <denis.arnaud_github at m4x dot org>

# Docker build time environment variables
ENV container docker
ENV HOME /home/build
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
ENV SIM_DIR $HOME/dev/sim

# Switch to the `root` user for complementary installation and configuration
USER root
RUN dnf -y remove boost169-devel
RUN dnf -y install boost-devel boost-python3-devel
ADD resources/ssh-config $HOME/.ssh/config
RUN chown build.build $HOME/.ssh/config

# Switch to the `build` user
USER build

# Configure SSH
RUN ssh-keyscan github.com > $HOME/.ssh/known_hosts
RUN chmod 600 $HOME/.ssh/config $HOME/.ssh/known_hosts

# Prepare the build environment
RUN mkdir -p $SIM_DIR
WORKDIR $SIM_DIR

ADD resources/Rakefile resources/metasim.yaml.sample resources/fix-airinv-deprecated-error.patch resources/fix-tvlsim-deprecated-error.patch $SIM_DIR/
RUN mv $SIM_DIR/metasim.yaml.sample $SIM_DIR/metasim.yaml

# Build and deliver all the components
RUN rake checkout
RUN cd $SIM_DIR/workspace/src/airinv && \
    patch -p1 < ../../../fix-airinv-deprecated-error.patch && \
    cd $SIM_DIR
RUN cd $SIM_DIR/workspace/src/tvlsim && \
    patch -p1 < ../../../fix-tvlsim-deprecated-error.patch && \
    cd $SIM_DIR
RUN rake offline=true configure
RUN rake offline=true install
RUN rake offline=true dist

# Entry point
CMD ["/bin/bash"]

