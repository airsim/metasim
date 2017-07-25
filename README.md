MetaSim
=======

Development helpers for the simulator components.

# Pre-requisites
Please check that you have ruby and rake installed.

## Fedora/CentOS/RedHat
On Fedora, the packages can be installed with:
```bash
$ dnf -y install rubygem-rake ruby ruby-libs
```

## MacOS
On MacOS, HomeBrew already contains everything necessary for Ruby.

# Configuration
Copy the ``metasim.yaml.sample`` sample configuration file
as ``metasim.yaml``. Then, alter it according to your environment.
```bash
$ cp metasim.yaml.sample metasim.yaml
$ vi metasim.yaml
```

# Typical life-cycle
* Display the list of available targets:
```bash
$ rake --tasks
```

## (Git) Checkout
```bash
$ rake checkout
$ ls -l workspace/src
```

## Configure of the local builders (CMake)
```bash
$ rake offline=true configure
```

## Build and local installation
```bash
$ rake offline=true install
```

## Packaging and distribution
```bash
$ rake offline=true dist
```

