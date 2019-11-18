FROM alpine:3.8

EXPOSE 5900
EXPOSE 22
EXPOSE 45454

RUN apk add --no-cache git bash
RUN git clone https://github.com/foxlet/macOS-Simple-KVM.git /macOS-Simple-KVM && cd /macOS-Simple-KVM && git submodule update --init --recursive
RUN apk add --no-cache alpine-sdk zlib-dev bzip2-dev openssl-dev python3 && \
    cd /macOS-Simple-KVM/tools/dmg2img-src && make && mv dmg2img ../dmg2img && \
    cd /macOS-Simple-KVM && ./jumpstart.sh --catalina \
    apk del --purge alpine-sdk zlib-dev bzip2-dev openssl-dev python3

RUN apk add --no-cache qemu-system-x86_64 qemu-img openssh-client sshpass
RUN cd /macOS-Simple-KVM && qemu-img create -f qcow2 /macOS.img 64G
ADD docker.sh /macOS-Simple-KVM/
RUN chmod 775 /macOS-Simple-KVM/docker.sh

ENV KEYBOARD=en-us
WORKDIR /macOS-Simple-KVM

ENTRYPOINT ["/macOS-Simple-KVM/docker.sh"]
