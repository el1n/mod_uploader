#!/usr/bin/env zsh

unsetopt FUNCTION_ARGZERO

run() {
    echo "$0: running \`$@'"
    $@ || exit -1
}

host=$1

# ログイン用の鍵の転送
run ssh-copy-id -i ~/.ssh/vmware.id_rsa ${host}

# Subversion アクセス用の鍵の転送
run ssh ${host} "rm -f .ssh/svn.id_rsa"
run scp ~/.ssh/svn.id_rsa ${host}:.ssh/
run ssh ${host} "rm -f .ssh/svn.id_rsa.pub"
run scp ~/.ssh/svn.id_rsa.pub ${host}:.ssh/
run scp =(echo "Host columbia";
          echo "Port 443";
          echo "IdentityFile ~/.ssh/home.id_rsa") ${host}:.ssh/config

# 基本ツールのインストール
run ssh ${host} "sudo yum -y update"
run ssh ${host} "sudo yum -y install yum-fastestmirror"
run ssh ${host} "sudo yum -y install zsh"
run ssh ${host} "sudo yum -y install emacs-nox"
run ssh ${host} "sudo yum -y install subversion"

# Z Shell の環境を整える
run ssh ${host} "sudo chsh -s /bin/zsh ${USER}"
run scp =(echo "PROMPT='%{$fg[$(load_color)]%}%B$USER@%m%#%b '";
          echo "autoload -U compinit";
          echo "compinit -u";
          echo "HISTFILE=$HOME/.zsh_history";
          echo "HISTSIZE=1000000";
          echo "SAVEHIST=1000000";
          echo "setopt share_history") ${host}:.zshrc
run scp =(echo "export LANG=C";
          echo "export PATH=$PATH:$HOME/bin") ${host}:.zshenv

# keychain をインストール
run ssh ${host} "mkdir -p bin"
run scp /usr/bin/keychain ${host}:bin/

# known_hosts の追加
run ssh ${host} "ssh-keyscan -p 443 -t rsa columbia > .ssh/known_hosts"
run ssh ${host} "ssh-keyscan -H -p 443 -t rsa columbia >> .ssh/known_hosts"

# mod_uploader に必要なパッケージのインストール
run ssh ${host} "sudo yum -y install gcc-c++"
run ssh ${host} "sudo yum -y install make"
run ssh ${host} "sudo yum -y install libtool"
run ssh ${host} "sudo yum -y install httpd-devel"

if [ ${host} = fedora ]; then
    run ssh ${host} "sudo yum -y install nkf"
    run ssh ${host} "sudo yum -y install perl-WWW-Mechanize"
    run ssh ${host} "sudo yum -y install perl-Test-Simple"
fi

# NOTE: テストに必要な Perl WWW::Mechanize が yum に無い場合 CPAN でインストールする

# リポジトリからチェックアウト
run ssh ${host} "bin/keychain ~/.ssh/*.id_rsa"
run ssh ${host} "mkdir -p prog"
run ssh ${host} "source ~/.keychain/${host}*-sh; cd prog; svn co svn+ssh://svn@columbia/storage/svn/repos/prog/Apache"
