use strict;
use warnings;

use Test::More tests => 2;

use Udev::FFI;

my $udev_version = Udev::FFI::udev_version();
diag($@)
    unless defined($udev_version);

isnt($udev_version, undef, "Get udev library version");

my $udev = eval { Udev::FFI->new() };
diag("Can't create Udev::FFI object. Udev library version is ".
    (defined($udev_version) ?$udev_version :'unknown')." Error message: $@.")
    if $@;

isa_ok $udev, 'Udev::FFI';