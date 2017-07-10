package Udev::FFI::Enumerate;

use strict;
use warnings;

use Udev::FFI::FFIFunctions;



sub new {
    my $class = shift;

    my $self = {
        _enumerate => shift
    };

    bless $self, $class;

    return $self;
}



sub get_udev {
    my $self = shift;

    return udev_enumerate_get_udev($self->{_enumerate});
}



sub DESTROY {
    my $self = shift;

    udev_enumerate_unref( $self->{_device} );
}



1;