# MacOS Docker container

This makes it super simple to host your own OSX docker container for build/ci purposes.

## Installation

You have to setup first an macOS installation (which is basically you going through the installer).

```
docker build -t macos .
qemu-img create -f qcow2 ./macOS.img 35G
docker run -ti --rm --name macos --privileged -v `pwd`/macOS.img:/macOS.img --name macos -p 5900:5900 macos:latest install
```

Open now a VNC client and connect to `localhost:5900`. Go through the installer wizard.

Note1: Make sure to create a user with username `macos` and password `macos`.
Note2: Make sure to enable "Remote Login": Settings > Share > Remote Login.


## Usage

You can now start the container. This boots the macOS and allows you to connect to its SSH or VNC port.

```
docker run -ti --rm --name macos --privileged -v `pwd`/macOS.img:/macOS.img -p 5900:5900 -p 2222:22 -p 45454:45454 macos:latest

ssh server@localhost -p 2222
```


# For macOS Host

If you use macOS as host you need to use a different docker-machine like virtualbox or VMWare Fusion with enabled VT-X support.
Here is a tutorial on how to use an macOS guest inside docker of an macOS Host:

1. Install VMWare fusion
2. Create docker host: `docker-machine create --driver vmwarefusion --vmwarefusion-cpu-count 8 --vmwarefusion-disk-size 40000 --vmwarefusion-memory-size 8000  default`
2.1. It might fail, but just continue:
3. docker-machine regenerate-certs --force default
4. `vmrun addSharedFolder `vmrun list |grep default` Users /Users`
5. `docker-machine stop default`
6. `docker-machine start default`
7. `eval $(docker-machine env default)`
8. Check if your new machine works: `docker ps`
9. Check if your new machine works: `docker run -ti -v /Users:/Users alpine ls -al /Users`. You should see your home folders.
10. Enable kvm: `docker-machine ssh default sudo modprobe kvm_intel`
