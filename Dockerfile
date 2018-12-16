#
# http://github.com/airsim/metasim/tree/master
#
FROM cpppythondevelopment/base:centos
MAINTAINER Denis Arnaud <denis.arnaud_github at m4x dot org>

# Docker build time environment variables
ENV container docker
ENV HOME /home/build

# Entry point
CMD ["/bin/bash"]

