use strict;
use warnings;

use Test::More tests => 1;

use Udev::FFI;

my $udev = eval { Udev::FFI->new() };
diag $@
    if $@;

isa_ok $udev, 'Udev::FFI';