FROM docker.io/library/archlinux@sha256:35fc5090fb0be52698eeb31202c4073746b2977a5f169722dd54c9914b1f38f4

# renovate: datasource=github-releases depName=todxx/teamredminer
ENV TRM_VERSION=v0.8.3

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

RUN curl -L https://github.com/todxx/teamredminer/releases/download/"${TRM_VERSION}"/teamredminer-"${TRM_VERSION}"-linux.tgz | tar xvz && \
    mv /teamredminer-"${TRM_VERSION}"-linux/* /teamredminer  && \
    rm -rf teamredminer-"${TRM_VERSION}"-linux

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

LABEL org.opencontainers.image.source = "https://github.com/anthr76/teamredminer-container"
