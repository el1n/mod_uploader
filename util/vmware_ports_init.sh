#!/usr/bin/env zsh

unsetopt FUNCTION_ARGZERO

run() {
    echo "$0: running \`$@'"
    $@ || exit -1
}

host=$1
sudo_portinstall="sudo env WITHOUT_X11=yes /usr/local/sbin/portinstall"

# �������Ѥθ���ž��
run ssh-copy-id -i ~/.ssh/vmware.id_rsa ${host}

# Subversion ���������Ѥθ���ž��
run ssh ${host} "rm -f .ssh/svn.id_rsa"
run scp ~/.ssh/svn.id_rsa ${host}:.ssh/
run ssh ${host} "rm -f .ssh/svn.id_rsa.pub"
run scp ~/.ssh/svn.id_rsa.pub ${host}:.ssh/
run scp =(echo "Host columbia";
          echo "Port 443";
          echo "IdentityFile ~/.ssh/home.id_rsa") ${host}:.ssh/config

# ���ܥġ���Υ��󥹥ȡ���
run ssh -t ${host} "if [ ! -e /usr/ports/ports-mgmt/portupgrade ]; then sudo portsnap fetch extract update; fi"
run ssh ${host} "cd /usr/ports/ports-mgmt/portupgrade; sudo make BATCH=yes install"

run ssh ${host} "${sudo_portinstall} --new --batch shells/zsh"
run ssh ${host} "${sudo_portinstall} --new --batch editors/emacs-devel"
run ssh ${host} "${sudo_portinstall} --new --batch devel/subversion"

# Z Shell �δĶ���������
run ssh ${host} "sudo chsh -s /usr/local/bin/zsh ${USER}"
run scp =(echo "PROMPT='%{$fg[$(load_color)]%}%B$USER@%m%#%b '";
          echo "autoload -U compinit";
          echo "compinit -u";
          echo "HISTFILE=$HOME/.zsh_history";
          echo "HISTSIZE=1000000";
          echo "SAVEHIST=1000000";
          echo "setopt share_history") ${host}:.zshrc
run scp =(echo "export LANG=C";
          echo "export PATH=$PATH:/usr/sbin:$HOME/bin") ${host}:.zshenv

# keychain �򥤥󥹥ȡ���
run ssh ${host} "mkdir -p bin"
run scp /usr/bin/keychain ${host}:bin/

# known_hosts ���ɲ�
run ssh ${host} "ssh-keyscan -p 443 -t dsa columbia.green-rabbit.net > .ssh/known_hosts"

# mod_uploader ��ɬ�פʥѥå������Υ��󥹥ȡ���
run ssh ${host} "${sudo_portinstall} --new --batch www/apache22"

run ssh ${host} "${sudo_portinstall} --new --batch www/p5-WWW-Mechanize"
run ssh ${host} "${sudo_portinstall} --new --batch japanese/nkf"

run ssh ${host} "sudo chmod 777 /var/run/"

# ��ݥ��ȥ꤫������å�������
run ssh ${host} "bin/keychain ~/.ssh/*.id_rsa"
run ssh ${host} "mkdir -p prog"
run ssh ${host} "source ~/.keychain/${host}*-sh; cd prog; svn co svn+ssh://svn@columbia/storage/svn/repos/prog/Apache"
