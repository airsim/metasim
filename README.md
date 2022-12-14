MetaSim - Umbrella project for the Travel Market Simulator (TvlSim / AirSim)
============================================================================

[![Docker Cloud build status](https://img.shields.io/docker/cloud/build/infrahelpers/tvlsim)](https://hub.docker.com/repository/docker/infrahelpers/tvlsim/general)
[![Docker Repository on Quay](https://quay.io/repository/tvlsim/metasim/status "Docker Repository on Quay")](https://quay.io/repository/tvlsim/metasim)

Development helpers for the simulator components.

The `metasim` project itself is an umbrella, allowing to drive all
the other components from a central local directory, namely `workspace/`.
One can then interact with any specific component directly by jumping
(`cd`-ing) into the corresponding directory. Software code can be edited
and committed directly from that component sub-directory.

[Docker images, hosted on Docker Cloud](https://hub.docker.com/r/infrahelpers/tvlsim/),
are provided for convenience reason, avoiding the need to set up
a proper development environment: they provide a ready-to-use,
ready-to-develop, ready-to-contribute environment. Enjoy!

# References
* Travel/Airline Market Simulator (TvlSim / AirSim):
  + Source code on GitHub: https://github.com/airsim
  + Docker Cloud repository: https://hub.docker.com/r/infrahelpers/tvlsim/
  + Official Web site: https://travel-sim.org

# Run the Docker image
* As a quick starter, some test cases can be launched from the
  [one of Docker images (_eg_, CentOS, Ubuntu or Debian)](docker/):
```bash
$ docker run --rm -it infrahelpers/tvlsim:centos bash
[build@c..5 metasim]$ cd workspace/build/tvlsim
[build@c..5 tvlsim (master)]$ make check
[build@c..5 tvlsim (master)]$ exit
```

# Meta-build
The [Docker images](https://cloud.docker.com/u/tvlsim/repository/docker/tvlsim/metasim)
come with all the dependencies already installed. If there is a need,
however, for some more customization (for instance, install some
other software products such as [Kafka](https://kafka.apache.org) or
[ElasticSearch](http://elasticsearch.com)), this section describes
how to get the end-to-end travel market simulator up
and running on a native environment (as opposed to within
a Docker container).

An alternative is to develop your own Docker image from the
[ones provided by that project](https://cloud.docker.com/u/tvlsim/repository/docker/tvlsim/metasim).
You would typically start the `Dockerfile` with
`FROM infrahelpers/tvlsim:<linux-distribution>`.

## Installation of dependencies (if not using the Docker image)
C++, Python and Ruby are needed in order to build
and run the various components of that project.

## Docker images
The [maintained Docker images for that project](docker/)
come with all the necessary pieces of software. They can either be used
_as is_, or used as inspiration for _ad hoc_ setup on other configurations.

## Native environment (outside of Docker)

### CentOS/RedHat
* Install [EPEL for CentOS/RedHat](https://fedoraproject.org/wiki/EPEL):
```bash
$ sudo rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official && \
  sudo rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Testing
$ sudo yum -y install epel-release
```

* Add the repository for CodeReady Linux Builder (CRB)
```bash
$ sudo dnf -y install 'dnf-command(config-manager)'
$ sudo dnf config-manager --set-enabled crb
```

* Add EPEL support
```bash
$ sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
```

* Install a few packages:
```bash
$ sudo dnf -y install less htop net-tools which sudo man vim \
        git-all wget curl file bash-completion keyutils Lmod \
        xz-devel zlib-devel bzip2-devel gzip tar rpmconf yum-utils \
        gcc gcc-c++ cmake m4 \
	lcov cppunit-devel \
        zeromq-devel czmq-devel cppzmq-devel \
        boost-devel xapian-core-devel openssl-devel libffi-devel \
        mpich-devel openmpi-devel \
        readline-devel sqlite-devel mariadb-devel \
        soci-mysql-devel soci-sqlite3-devel \
        libicu-devel protobuf-devel protobuf-compiler \
        python-devel \
        python3-mod_wsgi \
        geos-devel geos-python \
        doxygen ghostscript "tex(latex)" texlive-epstopdf-bin \
	rake rubygem-rake ruby-libs
```

### MacOS
* Install [Homebrew](https://brew.sh), if not already done:
```bash
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

* SOCI. When SOCI has to be built from the sources,
  the following shows how to do that:
```bash
$ mkdir -p ~/dev/infra/soci && cd ~/dev/infra/soci
$ git clone https://github.com/SOCI/soci.git
$ cd soci
$ mkdir build && cd build
$ cmake -DSOCI_TESTS=OFF ..
$ make
$ sudo make install
```

* C++, Python and Ruby:
```bash
$ brew install boost boost-python boost-python3 cmake libedit \
  sqlite mysql icu4c protobuf protobuf-c zeromq doxygen
$ wget https://raw.githubusercontent.com/zeromq/cppzmq/master/zmq.hpp -O /usr/local/include/zmq.hpp
$ brew install readline homebrew/portable-ruby/portable-readline
$ brew install pyenv
$ brew install rbenv ruby-build
```

### All
* Install Python [Pyenv] and [`pipenv`](https://pipenv.readthedocs.io):
```bash
$ git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv
$ cat >> ~/.bashrc << _EOF

# Python pyenv
export PYENV_ROOT="\${HOME}/.pyenv"
export PATH="\${PYENV_ROOT}/bin:\${PATH}"

if command -v pyenv 1>/dev/null 2>&1; then
    eval "\$(pyenv init -)"
fi
_EOF
$ source ${HOME}/.bashrc && pyenv install 3.10.9 && \
  pyenv global 3.10.9
$ python -mpip install -U pip
$ python -mpip install -U pipenv scikit-build build wheel setuptools pytest twine
```

## Clone the Git repository
The following operation needs to be done only on a native environment (as
opposed to within a Docker container).
The Docker image indeed comes with that Git repository already cloned and built.
In the following, `<linux-distrib>` may be one of `centos`, `ubuntu` or `debian`.
```bash
$ mkdir -p ~/dev/sim && cd ~/dev/sim
$ git clone https://github.com/airsim/metasim.git
$ cd metasim
$ cp docker/<linux-distrib>/resources/metasim.yaml.sample metasim.yaml
$ rake clone
$ rake checkout
$ rake offline=true info
```

## Interactive build with `rake`
That operation may be done either from within the Docker container,
or in a native environment (on which the dependencies have been installed).

As a reminder, to enter into the container, just type
`docker run --rm -it tvlsim/metasim:<linux-distrib> bash`, and `exit`
to leave it (`<linux-distrib>` may be one of `centos`, `ubuntu` or `debian`).

The following sequence of commands describes how to build, test and deliver
the artefacts of all the components, so that a full simulation may be performed:
```bash
$ cd ~/dev/sim/metasim
$ rm -rf workspace/build workspace/install
$ rake offline=true configure
$ rake offline=true install
$ rake offline=true test
$ rake offline=true dist
```

## Interacting with a specific project
Those operations may be done either from within the Docker container,
or in a native environment (on which the dependencies have been installed).

As a reminder, to enter into the container, just type
`docker run --rm -it tvlsim/metasim:<linux-distrib> bash`, and `exit`
to leave it (`<linux-distrib>` may be one of `centos`, `ubuntu` or `debian`).

```bash
$ cd ~/dev/sim/metasim
$ cd workspace/src/airinv
$ vi airinv/bom/LegCabinStruct.cpp
$ git add airinv/bom/LegCabinStruct.cpp
$ cd ../../build/airinv
$ make check && make install
$ # If all goes well at the component level, re-build the full simulator
$ cd ~/dev/sim/metasim
$ rake offline=true test
$ # If all goes well at the integration level
$ cd workspace/src/airinv
$ git commit -m "[Dev] Fixed issue #76: C++-20 compatibility"
$ cd -
```

## Batched build and Docker image generation
If the Docker images need to be re-built, the following commands explain
how to do it:
```bash
$ mkdir -p ~/dev/sim && cd ~/dev/sim
$ git clone https://github.com/airsim/metasim.git
$ cd metasim
$ docker build -t tvlsim/metasim:centos --squash docker/centos/
$ docker push tvlsim/metasim:centos
$ docker build -t tvlsim/metasim:debian --squash docker/debian/
$ docker push tvlsim/metasim:debian
$ docker build -t tvlsim/metasim:ubuntu --squash docker/ubuntu/
$ docker push tvlsim/metasim:ubuntu
$ docker images | grep "^bom4v"
REPOSITORY       TAG        IMAGE ID        CREATED             SIZE
tvlsim/metasim    centos       9a33eee22a3d    About an hour ago   2.16GB
tvlsim/metasim    debian       c5f1ea63a79b    2 hours ago         1.95GB
tvlsim/metasim    ubuntu       d5f1ea63a79c    2 hours ago         2.66GB
```

