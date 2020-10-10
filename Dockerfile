FROM fedora:latest

ARG SERPENT_TARGET

RUN dnf -y update && dnf -y upgrade

RUN dnf install -y curl wget file which sudo deltarpm

RUN echo "deltarpm=1" >> /etc/dnf/dnf.conf

RUN dnf install -y gcc gcc-c++ make gettext diffutils patch gettext-devel mtools texinfo python3 pigz bison ninja-build cmake libarchive bsdtar autoconf automake libtool zlib-devel xz-devel libzstd-devel openssl-devel

RUN dnf install -y qemu qemu-user-static

RUN dnf clean all

RUN curl https://raw.githubusercontent.com/junland/serpent-custom-bootstrap/main/run-stage3.sh > /usr/local/bin/run-stage3.sh

RUN chmod 777 /usr/local/bin/run-stage3.sh

RUN adduser -u 9000 builder && echo "builder:builder" | chpasswd && usermod -a -G wheel builder

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /opt/bootstrap

COPY --chown=builder:builder ./ /opt/bootstrap

RUN chown builder:builder -R /opt/bootstrap

WORKDIR /opt/bootstrap

RUN curl https://raw.githubusercontent.com/junland/serpent-custom-bootstrap/main/x86_64.txt > targets/x86_64.sh

RUN curl https://raw.githubusercontent.com/junland/serpent-custom-bootstrap/main/aarch64.txt > targets/aarch64.sh

USER builder

RUN cd stage1 && sed '4 i set +h' *.sh && ./stage1.sh

RUN cd stage2 && sed '4 i set +h' *.sh && ./stage2.sh
