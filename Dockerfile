FROM debian:jessie
MAINTAINER Naoaki Obiki
ARG username="9zilla"
ARG password="9zilla"
RUN apt-get update
RUN apt-get install -y make gcc g++ lsb-release
RUN apt-get install -y vim git tig bzip2 unzip tree sed bash-completion dbus sudo openssl curl wget expect cron
RUN apt-get install -y vim dnsutils procps siege pandoc locales dialog htop inetutils-traceroute iftop bmon iptraf nload slurm sl toilet lolcat
RUN mkdir /home/$username
RUN useradd -s /bin/bash -d /home/$username $username && echo "$username:$password" | chpasswd
RUN echo ${username}' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/$username
RUN mkdir -p /home/$username/ci/
RUN chown -R $username:$username /home/$username
RUN mkdir /var/workspace/
RUN ln -s /var/workspace/ /home/$username/workspace
RUN chown $username:$username /home/$username/workspace
RUN locale-gen ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN apt-get install -y chrony
RUN sed -ri "s/^server 0.debian.pool.ntp.org/#server 0.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 1.debian.pool.ntp.org/#server 1.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 2.debian.pool.ntp.org/#server 2.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 3.debian.pool.ntp.org/#server 3.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN echo "server ntp0.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp1.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp2.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "allow 172.18/12" >> /etc/chrony/chrony.conf
RUN systemctl enable chrony
RUN sudo -u $username mkdir -p /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username git clone "https://nobiki@bitbucket.org/nobiki/dotfiles.git" /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username cp /etc/bash.bashrc /home/$username/.bashrc
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.bash_profile /home/$username/.bash_profile
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.gitconfig /home/$username/.gitconfig
RUN sudo -u $username mkdir -p /home/$username/.ssh/
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.ssh/config /home/$username/.ssh/config
RUN curl -o /usr/local/bin/hcat "https://raw.githubusercontent.com/nobiki/bash-hcat/master/hcat"
RUN chmod +x /usr/local/bin/hcat
RUN curl -o /usr/local/bin/jq "http://stedolan.github.io/jq/download/linux64/jq"
RUN chmod +x /usr/local/bin/jq
ADD archives/peco_linux_amd64/peco /usr/local/bin/
RUN chmod +x /usr/local/bin/peco
RUN git clone "https://github.com/b4b4r07/enhancd.git" /usr/local/src/enhancd
RUN chmod +x /usr/local/src/enhancd/init.sh
RUN echo 'source /usr/local/src/enhancd/init.sh' >> /home/$username/.bash_profile
ENV HOME /home/$username
ENV ANYENV_HOME $HOME/.anyenv
ENV ANYENV_ENV $ANYENV_HOME/envs
RUN git clone "https://github.com/riywo/anyenv" $ANYENV_HOME
RUN echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> /home/$username/.bash_profile
RUN echo 'eval "$(anyenv init -)"' >> /home/$username/.bash_profile
ENV PATH $ANYENV_HOME/bin:$PATH
RUN mkdir $ANYENV_ENV
RUN chown -R $username:$username $ANYENV_HOME
RUN apt-get install -y vim-nox pkg-config libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libfreetype6-dev
RUN anyenv install pyenv
ENV PATH $ANYENV_ENV/pyenv/bin:$ANYENV_ENV/pyenv/shims:$PATH
ENV PYENV_ROOT $ANYENV_ENV/pyenv
RUN git clone "https://github.com/yyuu/pyenv-virtualenv" $PYENV_ROOT/plugins/pyenv-virtualenv
RUN chown -R $username:$username $ANYENV_HOME
RUN bash -c "cd /home/$username/ && exec $SHELL -l"
RUN mkdir /etc/uwsgi/
RUN echo "uWSGI==2.0.14" > /etc/uwsgi/packages.txt
RUN bash -c "cd /etc/uwsgi/ && pyenv install 3.5.0"
RUN bash -c "cd /etc/uwsgi/ && pyenv virtualenv 3.5.0 uwsgi"
RUN bash -c "cd /etc/uwsgi/ && pyenv local uwsgi"
RUN echo "3.5.0/envs/uwsgi" > /etc/uwsgi/.python-version
RUN bash -c "cd /etc/uwsgi/ && pip install -r packages.txt"
ADD settings/uwsgi/emperor.ini /etc/uwsgi/
ADD settings/uwsgi/application.ini.example /etc/uwsgi/
ADD settings/uwsgi/uwsgi.service /etc/systemd/system/
RUN mkdir /etc/uwsgi/sockets/
RUN chown www-data:www-data /etc/uwsgi/sockets/
RUN mkdir /var/log/uwsgi/
RUN chmod 666 /var/log/uwsgi/
RUN apt-get install -y nginx
ADD settings/nginx/nginx.conf /etc/nginx/nginx.conf
RUN anyenv install ndenv
RUN chown -R $username:$username $ANYENV_HOME
RUN apt-get install -y mariadb-client libmysqlclient-dev
