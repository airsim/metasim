#
# Dockerfile: http://github.com/airsim/metasim/tree/master/docker/debian/Dockerfile
# Docker Hub/Cloud page: https://cloud.docker.com/u/infrahelpers/repository/docker/infrahelpers/tvlsim
# Usual Docker tag: infrahelpers/tvlsim:debian
#
# Umbrella project for the Travel Market Simulator (TvlSim / AirSim)
#
# Base image:
# * Dockerfile: http://github.com/cpp-projects-showcase/docker-images/tree/master/debian11
# * Docker Hub/Cloud: https://cloud.docker.com/u/infrahelpers/repository/docker/infrahelpers/cpppython
# * Docker tag: infrahelpers/cpppython:debian11
#
FROM infrahelpers/cpppython:debian11

LABEL authors="Denis Arnaud <denis.arnaud_github at m4x dot org>"

# Docker build time environment variables
ENV container docker
ENV HOME /home/build
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8
ENV LC_ALL $LANG
ENV SIM_DIR $HOME/dev/sim

# Switch to the `root` user for complementary installation and configuration
USER root
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

ADD resources/Rakefile resources/metasim.yaml.sample $SIM_DIR/
RUN mv $SIM_DIR/metasim.yaml.sample $SIM_DIR/metasim.yaml

# Build and deliver all the components
RUN rake checkout && \
	rake offline=true configure && \
	rake offline=true install && \
	rake offline=true dist

# Entry point
CMD ["/bin/bash"]

