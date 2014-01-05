#!/usr/bin/env perl
###############################################################################
# Copyright (C) 2006 Tetsuya Kimata <kimata@acapulco.dyndns.org>
#
# All rights reserved.
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any
# damages arising from the use of this software.
#
# Permission is granted to anyone to use this software for any
# purpose, including commercial applications, and to alter it and
# redistribute it freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must
#    not claim that you wrote the original software. If you use this
#    software in a product, an acknowledgment in the product
#    documentation would be appreciated but is not required.
#
# 2. Altered source versions must be plainly marked as such, and must
#    not be misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source
#    distribution.
#
# $Id: vmware_test.pl,v 1.28 2008/02/16 02:50:41 kimata Exp $
###############################################################################

use strict;

use Expect;
use Term::ReadLine;
use Term::ReadPassword;
use Net::Ping::External qw{ ping };;
use File::Basename;

use constant BASE_DIR           => dirname($0) . '/../..';

use constant CMD_TIMEOUT_SEC    => 15;
use constant MAKE_TIMEOUT_SEC   => 3600;
use constant WINDOWS_HOSTNAME   => 'brazil';
use constant VMWARE_CMD_PATH    => 'C:/Application/Machine/VMware/VMware Server/vmware-cmd.bat';

use constant SHUTDOWN_WAIT_SEC  => 10;
use constant BOOT_INTERVAL_SEC  => 120;
use constant BOOT_WAIT_SEC      => 10;

my %VIRTUAL_MACHINE = (
    centos  => 'D:\\VMware\\CentOS\\CentOS.vmx',
    debian  => 'D:\\VMware\\Debian\\Debian.vmx',
    fedora  => 'D:\\VMware\\Fedora\\Fedora.vmx',
    freebsd => 'D:\\VMware\\FreeBSD\\FreeBSD.vmx',
    mandriva=> 'D:\\VMware\\Mandriva\\Mandriva.vmx',
    opensuse=> 'D:\\VMware\\openSUSE\\openSUSE.vmx',
    ubuntu  => 'D:\\VMware\\Ubuntu\\Ubuntu.vmx',
);

sub get_pass {
    return read_password(qq|pass: |);
}

sub create_exp {
    my $exp = Expect->new();
    $exp->raw_pty(0);
    return $exp;
}

sub ssh_login {
    my $exp = shift;
    my $pass = shift;

    $exp->spawn('cocot', qw(-t EUC-JP -p CP932 ssh), WINDOWS_HOSTNAME) or die $!;
    $exp->expect(CMD_TIMEOUT_SEC, 'password:');
    $exp->send($pass . "\n");
    $exp->expect(CMD_TIMEOUT_SEC, 'successfully');
}

sub set_env {
    my $exp = shift;

    $exp->send('cmd' . "\n");
    $exp->expect(CMD_TIMEOUT_SEC, '>');
}

sub exit_cmd {
    my $exp = shift;

    $exp->send('exit' . "\n");
    $exp->expect(MAKE_TIMEOUT_SEC, '$');
}

sub start_machine {
    my $exp = shift;
    my $name = shift;

    $exp->send('"' . VMWARE_CMD_PATH . '" ' . $VIRTUAL_MACHINE{$name} .
               ' start' . "\n");
    $exp->expect(CMD_TIMEOUT_SEC, '>');
}

sub stop_machine {
    my $exp = shift;
    my $name = shift;

    $exp->send('"' . VMWARE_CMD_PATH . '" ' . $VIRTUAL_MACHINE{$name} .
               ' stop hard' . "\n");
    $exp->expect(CMD_TIMEOUT_SEC, '>');
}

$| = 1;

my $user = $ENV{'USER'};
my $pass = $ENV{'WIN_PASS'} || get_pass();
my $exp = create_exp();

# ログイン
ssh_login($exp, $pass);
set_env($exp);

# バーチャルマシンの起動
foreach my $name (sort keys %VIRTUAL_MACHINE) {
    if (ping(host => $name)) {
        next;
    }
    start_machine($exp, $name);
    sleep(BOOT_INTERVAL_SEC);
}

# バーチャルマシンの起動待ち
while (1) {
    my $not_ready = 0;

    foreach my $name (sort keys %VIRTUAL_MACHINE) {
        if (system("ssh-keyscan -t rsa $name >/dev/null 2>&1") != 0) {
            printf("%s is not ready.\n", $name);
            $not_ready++;
        }
    }
    sleep(BOOT_WAIT_SEC);

    if ($not_ready == 0) {
        last;
    }
}

# テストの実行
system("make -C @{[BASE_DIR]} -f GNUmakefile.dist test-linux");
system("make -C @{[BASE_DIR]} -f GNUmakefile.dist test-bsd");

# shutdown コマンドの発行
foreach my $name (sort keys %VIRTUAL_MACHINE) {
    if ($name =~ /bsd/i) {
        system("ssh $name sudo /sbin/shutdown -p now");
    } else {
        system("ssh $name sudo /sbin/shutdown -h now");
    }
}

while (1) {
    my $alive = 0;

    foreach my $name (sort keys %VIRTUAL_MACHINE) {
        if (ping(host => $name)) {
            $alive++;
        }
    }
    sleep(SHUTDOWN_WAIT_SEC);

    if ($alive == 0) {
        last;
    }
}

# バーチャルマシンの停止
foreach my $name (sort keys %VIRTUAL_MACHINE) {
    stop_machine($exp, $name);
}
exit_cmd($exp);

# テストの結果表示
system("make -C @{[BASE_DIR]} -f GNUmakefile.dist test-linux-status");
system("make -C @{[BASE_DIR]} -f GNUmakefile.dist test-bsd-status");

# Local Variables:
# mode: cperl
# coding: euc-japan-unix
# End:
