FROM ababup1192/dev-base:0.1
MAINTAINER ababup1192 ababup1192@gmail.com

# ==== ENV ====

# [Please set a your info]
ENV user_id   dev
ENV user_pass dev
ENV git_mail  ababup1192@gmail.com
ENV git_name  ababup1192
ENV RUBY_VERSION 2.0.0-p643

# Initial setting
RUN apt-get update

# Git setting
RUN git config --global user.email "$git_mail" && git config --global user.name "$git_name"

# Setup Root User
RUN echo 'root:screencast' | chpasswd

# Create SSH User
RUN useradd $user_id -m -s /bin/zsh
RUN echo "$user_id":"$user_pass" | chpasswd
RUN echo "$user_id ALL=(ALL) ALL" >> /etc/sudoers.d/$user_id
RUN mkdir -p /home/$user_id/.ssh; chown $user_id /home/$user_id/.ssh; chmod 700 /home/$user_id/.ssh

# Setup SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Setup prezto
USER $user_id

RUN curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
RUN git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
RUN git clone https://github.com/ababup1192/dotfiles.git /tmp/dotfiles && \
 cp -r /tmp/dotfiles/.??* /home/$user_id
RUN rm -rf /var/tmp/dotfiles

# ==== Ruby ====
USER $user_id

RUN git clone git://github.com/sstephenson/rbenv.git ~/.rbenv && \
  git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  exec /bin/zsh
RUN /bin/zsh -c "rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION" && \
  echo "gem: --no-ri --no-rdoc" > ~/.gemrc && /bin/zsh -c "gem install bundler"

# ==== Vim ====
WORKDIR /home/$user_id
RUN /bin/zsh -c "gem install rubocop refe2 && bitclust setup"
USER root
RUN apt-get install -y vim-nox

# ==== Supervisord ====

# Clone project file
RUN git clone https://gist.github.com/2769f1d01d152b111b5a.git /home/$user_id/app

USER root

ADD service.conf /etc/supervisor/conf.d/

RUN apt-get install -y supervisor && \
 apt-get install python-setuptools && \
 easy_install superlance && \
 rm -rf /var/lib/apt/lists/* && \
 sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf

WORKDIR /etc/supervisor/conf.d
CMD ["supervisord", "-c",  "/etc/supervisor/supervisord.conf"]

