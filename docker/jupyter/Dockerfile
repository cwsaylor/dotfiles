FROM quay.io/jupyter/base-notebook:latest

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for Ruby
#    curl autoconf patch build-essential rustc libssl-dev
#    libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev
#    libncurses5-dev libffi-dev libgdbm6 libgdbm-dev
#    libdb-dev uuid-dev

# Install dependencies required for iRuby
#    libzmq3-dev libffi-dev libtool git

# Install additional scientific computing dependencies
#    libgsl-dev libfftw3-dev libblas-dev liblapack-dev
#    texlive-xetex texlive-fonts-recommended texlive-plain-generic

# Install rustc stuff
#    pkg-config libfontconfig1-dev

RUN apt update && apt install -y --no-install-recommends \
    curl autoconf patch build-essential rustc libssl-dev \
    libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev \
    libncurses5-dev libffi-dev libgdbm6 libgdbm-dev \
    libdb-dev uuid-dev libzmq3-dev libtool git \
    libgsl-dev libfftw3-dev libblas-dev liblapack-dev \
    texlive-xetex texlive-fonts-recommended texlive-plain-generic \
    pkg-config libfontconfig1-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Mise in a global location
RUN curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise sh

# Switch back to the notebook user
USER jovyan

# Add Mise to the environment PATH (so it's available in all shells)
ENV PATH="/home/jovyan/.local/share/mise/shims:/home/jovyan/.local/bin:/usr/local/bin/mise/bin:$PATH"

# Install and globally set Ruby
RUN echo 'eval "$(mise activate bash)"' >> ~/.bashrc
RUN mise use -g ruby@3.4.2 node@20 rust@latest
RUN gem update --system
RUN gem install iruby && iruby register --force
RUN npm install -g ijavascript && ijsinstall
RUN mise use -g cargo:evcxr_jupyter && evcxr_jupyter --install
