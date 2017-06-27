# Udev::FFI - Copyright (C) 2017 Ilya Pavlov
# Udev::FFI is licensed under the
# GNU Lesser General Public License v2.1

package Udev::FFI::Device;

use strict;
use warnings;

use Udev::FFI::FFIFunctions;



sub new {
    my $class = shift;
    my $monitor = shift;

    my $self = {
        _device => udev_monitor_receive_device($monitor)
    };

    if(!defined($self->{_device})) {
        return undef;
    }

    bless $self, $class;

    return $self;
}



sub get_devpath {
    my $self = shift;

    return udev_device_get_devpath($self->{_device});
}


sub get_subsystem {
    my $self = shift;

    return udev_device_get_subsystem($self->{_device});
}


sub get_devtype {
    my $self = shift;

    return udev_device_get_devtype($self->{_device});
}


sub get_syspath {
    my $self = shift;

    return udev_device_get_syspath($self->{_device});
}


sub get_sysname {
    my $self = shift;

    return udev_device_get_sysname($self->{_device});
}


sub get_sysnum {
    my $self = shift;

    return udev_device_get_sysnum($self->{_device});
}


sub get_devnode {
    my $self = shift;

    return udev_device_get_devnode($self->{_device});
}


sub get_is_initialized {
    my $self = shift;

    return udev_device_get_is_initialized($self->{_device});
}


sub get_property_value {
    my $self = shift;
    my $key = shift;

    return udev_device_get_property_value($self->{_device}, $key);
}


sub get_driver {
    my $self = shift;

    return udev_device_get_driver($self->{_device});
}


sub get_action {
    my $self = shift;

    return udev_device_get_action($self->{_device});
}


sub get_seqnum {
    my $self = shift;

    return udev_device_get_seqnum($self->{_device});
}


sub get_usec_since_initialized {
    my $self = shift;

    return udev_device_get_usec_since_initialized($self->{_device});
}


sub get_sysattr_value {
    my $self = shift;
    my $sysattr = shift;

    return udev_device_get_sysattr_value($self->{_device}, $sysattr);
}


sub set_sysattr_value {
    my $self = shift;
    my $sysattr = shift;
    my $value = shift;

    return udev_device_set_sysattr_value($self->{_device}, $sysattr, $value);
}


sub has_tag {
    my $self = shift;
    my $tag = shift;

    return udev_device_has_tag($self->{_device}, $tag);
}



sub DESTROY {
    my $self = shift;

    udev_device_unref( $self->{_device} );
}



1;