# Udev::FFI - Copyright (C) 2017 Ilya Pavlov
# Udev::FFI is licensed under the
# GNU Lesser General Public License v2.1

package Udev::FFI;

use strict;
use warnings;

use Udev::FFI::FFIFunctions;
use Udev::FFI::Monitor;

use IPC::Cmd qw(can_run run);


$Udev::FFI::VERSION = '0.000001';


use constant {
    UDEVADM_LOCATIONS => [
        '/bin/udevadm'
    ]
};



sub udev_version {
    my $full_path = can_run('udevadm');

    if(!$full_path) {
        for(@{ +UDEVADM_LOCATIONS }) {
            if(-f) {
                $full_path = $_;
                last;
            }
        }
    }

    if(!$full_path) {
        $@ = "Can't find udevadm utility";
        return undef;
    }


    my ( $success, $error_message, undef, $stdout_buf, $stderr_buf ) =
        run( command => [$full_path, '--version'], timeout => 60, verbose => 0 );

    if(!$success) {
        $@ = $error_message;
        return undef;
    }
    if($stdout_buf->[0] !~ /^(\d+)\s*$/) {
        $@ = "Can't get udev version";
        return undef;
    }

    return $1;
}



sub new {
    my $class = shift;

    my $self = {};

    if(0 == Udev::FFI::FFIFunctions->load_lib()) {
        $@ = "Can't find udev library";
        return undef;
    }

    $self->{_context} = udev_new();
    if(!defined($self->{_context})) {
        $@ = "Can't create udev context.";
        return undef;
    }


    bless $self, $class;

    return $self;
}



sub new_monitor {
    my $self = shift;

    return Udev::FFI::Monitor->new($self->{_context});
}



sub DESTROY {
    my $self = shift;

    udev_unref( $self->{_context} );
}



1;