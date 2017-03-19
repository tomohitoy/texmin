#
# Base
#

FROM ubuntu:14.04
MAINTAINER tomohitoy t07840ty@gmail.com

RUN apt-get update -y
RUN chmod go+w,u+s /tmp

# package
RUN apt-get install openssh-server zsh build-essential -y
RUN apt-get install wget unzip curl tree grep bison libssl-dev openssl zlib1g-dev -y # "libssl-dev openssl zlib1g-dev" need to rbenv and pyenv

#vim
RUN apt-get install git mercurial gettext libncurses5-dev  libperl-dev python-dev python3-dev lua5.2 liblua5.2-dev luajit libluajit-5.1 gfortran libopenblas-dev liblapack-dev -y
RUN cd /tmp \
    && git clone https://github.com/vim/vim.git \
    && cd /tmp/vim \
    && ./configure --with-features=huge --enable-perlinterp --enable-pythoninterp --enable-python3interp --enable-luainterp --with-luajit --enable-fail-if-missing \
    && make \
    && make install

# sshd config
RUN sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd
RUN mkdir /var/run/sshd

# user
RUN echo 'root:root' |chpasswd
RUN useradd -m tomohitoy \
    && echo "tomohitoy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo 'tomohitoy:tomohitoy' | chpasswd
RUN chsh tomohitoy -s $(which zsh)

USER tomohitoy
WORKDIR /home/tomohitoy
ENV HOME /home/tomohitoy

# ssh
RUN mkdir .ssh
ADD id_rsa.pub .ssh/authorized_keys
USER root
RUN chown tomohitoy:tomohitoy -R /home/tomohitoy
RUN chmod 700 .ssh
USER tomohitoy


# dotfiles
RUN git clone https://github.com/tomohitoy/dotfiles.git ~/dotfiles \
    && cd ~/dotfiles \
    && bash bootstrap.sh

#
# Database
#

USER root
# client
RUN apt-get install postgresql-client mongodb-clients -y
USER tomohitoy

#
# Programming Language
#
# Python (virtualenv)
USER root
RUN apt-get install python-pip -y
RUN pip install virtualenv
RUN pip install virtualenvwrapper
USER tomohitoy
RUN echo 'export WORKON_HOME=$HOME/.virtualenvs' >> ~/.zshrc
RUN echo 'source `which virtualenvwrapper.sh`' >> ~/.zshrc

# Python (pyenv)
RUN git clone https://github.com/yyuu/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc
RUN ~/.pyenv/bin/pyenv install anaconda-4.3.0
RUN ~/.pyenv/bin/pyenv global anaconda-4.3.0
RUN ~/.pyenv/bin/pyenv rehash
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt
#
# install phantomjs
RUN git clone git://github.com/ariya/phantomjs.git ~/.phantomjs
RUN cd ~/.phantomjs
RUN git checkout 2.0
RUN ./build.sh
USER root
RUN cp ~/.phantomjs/bin/phantomjs /usr/local/bin/

# volumes
USER tomohitoy
RUN mkdir /home/tomohitoy/works

# for ssh
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
