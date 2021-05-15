FROM docker.io/archlinux:base-devel-20210509.0.21942

ENV TRM_VERSION=0.8.2.1

RUN pacman -Syu --noconfirm --needed base base-devel git asp && \
    useradd -d /home/makepkg makepkg && \
    mkdir -p /home/makepkg/{.config/pacman,.gnupg,out} && \
    echo 'MAKEFLAGS="-j$(nproc)"' >> /home/makepkg/.config/pacman/makepkg.conf && \
    echo 'PKGDEST="/home/makepkg/out"' >> /home/makepkg/.config/pacman/makepkg.conf && \
    echo 'keyserver-options auto-key-retrieve' > /home/makepkg/.gnupg/gpg.conf && \
    mkdir -p /teamredminer && \
    chown -R makepkg:users /home/makepkg

COPY sudoers /etc/sudoers

# https://github.com/todxx/teamredminer/issues/296#issuecomment-829532295
RUN git clone https://aur.archlinux.org/opencl-amd.git/ && \
    chown -R makepkg:users /opencl-amd && \
    cd /opencl-amd && \
    git checkout ef49efa && \ 
    sudo -u makepkg makepkg --noconfirm -si && \
    sudo -u makepkg makepkg --printsrcinfo > .SRCINFO && \
    cat .SRCINFO && \
    mv .SRCINFO /teamredminer && \
    cd .. && \
    rm -rf /opencl-amd

RUN curl -L https://github.com/todxx/teamredminer/releases/download/"${TRM_VERSION}"/teamredminer-v"${TRM_VERSION}"-linux.tgz | tar xvz && \
    mv /teamredminer-v"${TRM_VERSION}"-linux/* /teamredminer  && \
    rm -rf teamredminer-v"${TRM_VERSION}"-linux

RUN \
  useradd miner \
  --uid 2000 \
  --user-group \
  --system \
  --no-create-home \
  && chown -R miner:miner /teamredminer \
  && chmod -R 775 /teamredminer

RUN pacman --noconfirm -R $(pacman -Qtdq) && \
    pacman --noconfirm -Sc && \
    pacman --noconfirm -Scc

USER miner

WORKDIR /teamredminer
VOLUME [ "/teamredminer" ]
ENTRYPOINT ["./teamredminer"]