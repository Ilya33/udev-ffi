use strict;
use warnings;

use Test::More tests => 1;

use Udev::FFI;

my $udev = eval { return Udev::FFI->new() };
isa_ok $udev, 'Udev::FFI';