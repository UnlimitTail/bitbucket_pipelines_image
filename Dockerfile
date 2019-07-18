FROM ubuntu:16.04
MAINTAINER UnlimitTail Pipelines

SHELL ["/bin/bash", "-c"]

# Install base dependencies
RUN apt-get update \
    && apt-get install -y \
        software-properties-common \
        build-essential \
        checkinstall \
        wget \
        xvfb \
        curl \
        git \
        mercurial \
        maven \
        openjdk-8-jdk \
        ant \
        ssh-client \
        unzip \
        iputils-ping \
        libreadline-gplv2-dev \
        libncursesw5-dev \
        libssl-dev \
        libsqlite3-dev \
        tk-dev \
        libgdbm-dev \
        libc6-dev \
        libbz2-dev \
        python-pip\
        zlib1g-dev \
        libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile \
    && echo 'eval "$(pyenv init -)"' >> ~/.bash_profile

# Install virtualenv
RUN git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv \
    && echo 'export PYENV_VIRTUALENV_DISABLE_PROMPT=1' >> ~/.bash_profile \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile

# Install python3.6.4
RUN bash && source ~/.bash_profile \
    && pyenv install 3.6.4 \
    && pyenv versions

# Create virtualenv
RUN bash && source ~/.bash_profile \
    && pyenv virtualenv 3.6.4 py3.6.4

# Install nvm with node and npm
ENV NODE_VERSION=8.9.4 \
    NVM_DIR=/root/.nvm \
    NVM_VERSION=0.33.8

RUN curl https://raw.githubusercontent.com/creationix/nvm/v$NVM_VERSION/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Set node path
ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# Xvfb provide an in-memory X-session for tests that require a GUI
ENV DISPLAY=:99

# Install aws-cli
RUN pip install awscli --upgrade --user

# Install managers (on py3.6.4)
RUN bash && source ~/.bash_profile && source ~/.pyenv/versions/3.6.4/envs/py3.6.4/bin/activate \
    && pip install zappa

# Set the path.
ENV PATH=$NVM_DIR:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$HOME/.local/bin:$PATH

# Create dirs and users
RUN mkdir -p /opt/atlassian/bitbucketci/agent/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 pipelines

WORKDIR /opt/atlassian/bitbucketci/agent/build
ENTRYPOINT /bin/bash
