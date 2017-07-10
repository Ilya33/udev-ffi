# Udev::FFI - Copyright (C) 2017 Ilya Pavlov
# Udev::FFI is licensed under the
# GNU Lesser General Public License v2.1

package Udev::FFI;

use strict;
use warnings;

use Udev::FFI::FFIFunctions;
use Udev::FFI::Device;
use Udev::FFI::Monitor;

use IPC::Cmd qw(can_run run);


$Udev::FFI::VERSION = '0.000005';


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



sub new_device_from_syspath {
    my $self = shift;
    my $syspath = shift;

    my $device = udev_device_new_from_syspath($self->{_context}, $syspath);
    if(defined($device)) {
        return Udev::FFI::Device->new( $device );
    }

    return undef;
}



sub new_device_from_devnum {
    my $self = shift;
    my $type = shift;
    my $devnum = shift;

    my $device = udev_device_new_from_devnum($self->{_context}, ord($type), $devnum);
    if(defined($device)) {
        return Udev::FFI::Device->new( $device );
    }

    return undef;
}



sub new_device_from_subsystem_sysname {
    my $self = shift;
    my $subsystem = shift;
    my $sysname = shift;

    my $device = udev_device_new_from_subsystem_sysname($self->{_context}, $subsystem, $sysname);
    if(defined($device)) {
        return Udev::FFI::Device->new( $device );
    }

    return undef;
}



sub new_device_from_device_id {
    my $self = shift;
    my $id = shift;

    my $device = udev_device_new_from_device_id($self->{_context}, $id);
    if(defined($device)) {
        return Udev::FFI::Device->new( $device );
    }

    return undef;
}



sub new_device_from_environment {
    my $self = shift;

    my $device = udev_device_new_from_environment($self->{_context});
    if(defined($device)) {
        return Udev::FFI::Device->new( $device );
    }

    return undef;
}



sub new_monitor {
    my $self = shift;
    my $source = shift || 'udev';

    if($source ne 'udev' && $source ne 'kernel') {
        $@ = 'Valid sources identifiers are "udev" and "kernel"';
        return undef;
    }

    my $monitor = udev_monitor_new_from_netlink($self->{_context}, $source);
    unless(defined($monitor)) {
        $@ = "Can't create udev monitor from netlink.";
        return undef;
    }

    return Udev::FFI::Monitor->new($monitor);
}



sub new_enumerate {
    my $self = shift;

    my $enumerate = udev_enumerate_new($self->{_context});
    unless(defined($enumerate)) {
        $@ = "Can't create enumerate context.";
        return undef;
    }

    return Udev::FFI::Enumerate->new($enumerate);
}



sub DESTROY {
    my $self = shift;

    udev_unref( $self->{_context} );
}



1;



__END__



=head1 NAME

Udev::FFI - Perl bindings for libudev using ffi

=head1 VERSION

version pre-alpha

=head1 SYNOPSIS

  use Udev::FFI;
  blah blah blah

=head1 DESCRIPTION

See examples.

Stub documentation for Udev::FFI.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Ilya Pavlov, E<lt>iluxz@mail.ruE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Ilya Pavlov


=cut