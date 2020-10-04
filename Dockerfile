FROM fedora:latest

ARG SERPENT_TARGET

RUN dnf -y update && dnf -y upgrade

RUN dnf install -y curl wget file which sudo deltarpm

RUN echo "deltarpm=1" >> /etc/dnf/dnf.conf

RUN dnf install -y gcc gcc-c++ make gettext diffutils patch gettext-devel mtools texinfo python3 pigz bison ninja-build cmake libarchive bsdtar autoconf automake libtool zlib-devel xz-devel libzstd-devel openssl-devel

RUN dnf clean all

RUN curl https://gist.githubusercontent.com/junland/c04a51daf4f11fe3ef54e94b581ac03b/raw/a5c439bf9b3fdc23e5d66a1235c13ee04e78b9cc/run-stage3.sh > /usr/local/bin/run-stage3.sh

RUN chmod 777 /usr/local/bin/run-stage3.sh

RUN adduser -u 9000 builder && echo "builder:builder" | chpasswd && usermod -a -G wheel builder

RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir -p /opt/bootstrap

COPY --chown=builder:builder ./ /opt/bootstrap

RUN chown builder:builder -R /opt/bootstrap

WORKDIR /opt/bootstrap

USER builder

RUN cd stage1 && ./stage1.sh

RUN cd stage2 && ./stage2.sh
