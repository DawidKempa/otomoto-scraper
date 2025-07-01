FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl gnupg2 build-essential libssl-dev libreadline-dev zlib1g-dev \
    sudo git autoconf bison libyaml-dev libsqlite3-dev sqlite3 libgdbm-dev libncurses5-dev libffi-dev libgmp-dev libtool pkg-config

RUN useradd -m -s /bin/bash hosting && echo 'hosting ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/hosting && cat /etc/passwd
USER hosting
WORKDIR /home/hosting

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    curl -sSL https://get.rvm.io | bash -s stable

ENV PATH="/home/hosting/.rvm/bin:$PATH"
RUN /bin/bash -l -c "rvm install 3.2.2 && rvm use 3.2.2 --default && gem install bundler"

RUN echo 'source /home/hosting/.rvm/scripts/rvm' >> /home/hosting/.bashrc

WORKDIR /home/hosting/app

CMD ["bash"]
