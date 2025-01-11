package Udev::FFI;

use strict;
use warnings;

use Udev::FFI::Functions qw(:all);
use Udev::FFI::Device;
use Udev::FFI::Monitor;
use Udev::FFI::Enumerate;

$Udev::FFI::VERSION = '0.105000';

*Udev::FFI::udev_version = \&Udev::FFI::Functions::udev_version;

sub new {
    my $class = shift;

    if (0 == Udev::FFI::Functions->init()) {
        return undef; # error already in $@
    }

    my $self = {_context => udev_new()};
    unless (defined($self->{_context})) {
        $@ = "Can't create udev context: $!";
        return undef;
    }

    bless($self, $class);

    return $self;
}



sub new_device_from_syspath {
    my $self = shift;
    my $syspath = shift;

    my $device = udev_device_new_from_syspath($self->{_context}, $syspath);

    return defined($device) ? Udev::FFI::Device->new($device, $self) : undef;
}



sub new_device_from_devnum {
    my $self = shift;
    my $type = shift;
    my $devnum = shift;

    my $device = udev_device_new_from_devnum($self->{_context}, ord($type), $devnum);

    return defined($device) ? Udev::FFI::Device->new($device, $self) : undef;
}



sub new_device_from_subsystem_sysname {
    my $self = shift;
    my $subsystem = shift;
    my $sysname = shift;

    my $device = udev_device_new_from_subsystem_sysname($self->{_context}, $subsystem, $sysname);

    return defined($device) ? Udev::FFI::Device->new($device, $self) : undef;
}



sub new_device_from_device_id {
    my $self = shift;
    my $id = shift;

    my $device = udev_device_new_from_device_id($self->{_context}, $id);

    return defined($device) ? Udev::FFI::Device->new($device, $self) : undef;
}



sub new_device_from_environment {
    my $self = shift;

    my $device = udev_device_new_from_environment($self->{_context});

    return defined($device) ? Udev::FFI::Device->new($device, $self) : undef;
}



sub new_monitor {
    my $self = shift;
    my $source = shift;

    $source = 'udev'
        unless (defined($source));

    my $monitor = udev_monitor_new_from_netlink($self->{_context}, $source);
    unless (defined($monitor)) {
        $@ = $! || "Can't create udev monitor from netlink";
        return undef;
    }

    return Udev::FFI::Monitor->new($monitor, $self);
}



sub new_enumerate {
    my $self = shift;

    my $enumerate = udev_enumerate_new($self->{_context});
    unless (defined($enumerate)) {
        $@ = $! || "Can't create enumerate context";
        return undef;
    }

    return Udev::FFI::Enumerate->new($enumerate, $self);
}



sub DESTROY {
    udev_unref($_[0]->{_context});
}



1;



__END__



=head1 NAME

Udev::FFI - Perl bindings for libudev using ffi.

=head1 SYNOPSIS

    use Udev::FFI;
    use Udev::FFI::Devnum qw(:all); # <- import major, minor and makedev
    
    # get udev library version
    my $udev_version = Udev::FFI::udev_version() or
        die("Can't get udev library version: $@");
    
    
    # create Udev::FFI object
    my $udev = Udev::FFI->new() or
        die("Can't create Udev::FFI object: $@");
    
    
    # create udev monitor
    my $monitor = $udev->new_monitor() or
        die("Can't create udev monitor: $@");
    
    # add filter to monitor
    unless ($monitor->filter_by_subsystem_devtype('block')) {
        warn("Ouch!");
    }
    
    # start monitor
    if ($monitor->start()) {
        for (;;) {
            # poll devices, now insert or remove your block device
            my $device = $monitor->poll(); # blocking read
            my $action = $device->get_action();
    
            print("ACTION: $action\n");
            print('SYSNAME: '.$device->get_sysname()."\n");
            print('DEVNODE: '.$device->get_devnode()."\n");
    
            last; # for example
        }
    
        for (;;) {
            # poll devices, now insert or remove your block device
            if (defined(my $device = $monitor->poll(0))) { # non-blocking read like can_read in IO::Select
                my $action = $device->get_action();
    
                print("ACTION: $action\n");
                print('SYSNAME: '.$device->get_sysname()."\n");
                print('DEVNODE: '.$device->get_devnode()."\n");
            }
    
            sleep(1);
    
            last; # for example
        }
    }
    
    
    # enumerate devices
    my $enumerate = $udev->new_enumerate() or
        die("Can't create enumerate context: $@");
    
    $enumerate->add_match_subsystem('block');
    $enumerate->scan_devices();
    
    use Data::Dumper; # for dump values in $href and @a
    
    # scalar context
    my $href = $enumerate->get_list_entries();
    print(Dumper($href)."\n");
    
    # list context
    my @a = $enumerate->get_list_entries();
    print(Dumper(@a)."\n");
    
    if (@a) { # we got devices
        my $device = $udev->new_device_from_syspath($a[0]);
    
        if (defined($device)) {
            print('Device: '.$device->get_sysname()."\n");
    
            my $devnum = $device->get_devnum();
    
            # major, minor and makedev from Udev::FFI::Devnum
            my ($ma, $mi) = (major($devnum), minor($devnum));
    
            print("Major: $ma\n");
            print("Minor: $mi\n");
    
            $devnum = makedev($ma, $mi);
            print("Devnum: $devnum\n");
    
    
            # scalar context
            $href = $device->get_properties_list_entries();
            print(Dumper($href)."\n");
    
            # list context
            @a = $device->get_properties_list_entries();
            print(Dumper(@a)."\n");
        }
    }

=head1 DESCRIPTION

Udev::FFI exposes OO interface to libudev.

=head1 CONSTRUCTOR
 
=over 4
 
=item new()
 
This is the constructor for a new Udev::FFI object.

If the constructor fails undef will be returned and an error message will be in
$@.

    my $udev = Udev::FFI->new() or
        die("Can't create Udev::FFI object: $@");

=back

=head1 METHODS

=head2 new_monitor( [SOURCE] )

Create new udev monitor and connect to a specified event source. Valid sources
identifiers are C<'udev'> and C<'kernel'>. This argument is optional and
defaults to C<'udev'>.

Return new L<Udev::FFI::Monitor> object on success, undef with the error in $@
on failure.

    my $monitor = $udev->new_monitor() or
        die("Can't create udev monitor: $@");

=head2 new_enumerate()

Create an enumeration context to scan /sys.

Return new L<Udev::FFI::Enumerate> object on success, undef with the error in $@
on failure.

    my $enumerate = $udev->new_enumerate() or
        die("Can't create enumerate context: $@");

=head2 new_device_from_syspath( SYSPATH )

Create new udev device, and fill in information from the sys device and the udev
database entry. The syspath is the absolute path to the device, including the
sys mount point.

Return new L<Udev::FFI::Device> object or undef, if device does not exist.

    my $device0 = $udev->new_device_from_syspath('/sys/class/block/sda1');
    my $device1 = $udev->new_device_from_syspath('/sys/class/net/eth0');
    
    # ... some code
    my @devices = $enumerate->get_list_entries();
    for (@devices) {
        my $device = $udev->new_device_from_syspath($_);
    # ... some code

=head2 new_device_from_devnum( TYPE, DEVNUM )

Create new udev device, and fill in information from the sys device and the udev
database entry. The device is looked-up by its type and major/minor number.

Return new L<Udev::FFI::Device> object or undef, if device does not exist.

    use Udev::FFI::Devnum qw(makedev);
    my $device0 = $udev->new_device_from_devnum('b', makedev(8, 1));
    my $device1 = $udev->new_device_from_devnum('c', makedev(189, 515));

=head2 new_device_from_subsystem_sysname( SUBSYSTEM, SYSNAME )

Create new udev device, and fill in information from the sys device and the udev
database entry. The device is looked up by the subsystem and name string of the
device.

Return new L<Udev::FFI::Device> object or undef, if device does not exist.

    my $device0 = $udev->new_device_from_subsystem_sysname('block', 'sda1');
    my $device1 = $udev->new_device_from_subsystem_sysname('net', 'lo');
    my $device2 = $udev->new_device_from_subsystem_sysname('mem', 'urandom');

=head2 new_device_from_device_id( ID )

Create new udev device, and fill in information from the sys device and the udev
database entry. The device is looked-up by a special string:

=over 8

C<'b8:1'> - block device major:minor

C<'c128:2'> - char device major:minor

C<'n2'> - network device ifindex

C<'+sound:card29'> - kernel driver core subsystem:device name

=back

Return new L<Udev::FFI::Device> object or undef, if device does not exist.

    my $device = $udev->new_device_from_device_id('b8:1');

=head2 new_device_from_environment()

Create new udev device, and fill in information from the current process
environment. This only works reliable if the process is called from a udev rule.

Return new L<Udev::FFI::Device> object or undef, if device does not exist.

    # in udev.rules (for example)
    # SUBSYSTEM=="backlight", ACTION=="change", IMPORT{program}="/path/script.pl"
    
    # in script
    my $udev = Udev::FFI->new() or
        die("Can't create Udev::FFI object: $@");
    my $device = $udev->new_device_from_environment();
    if (defined($device)) {
        # $device is the device from the udev rule (backlight in this example)
        # work with $device

=head2 Udev::FFI::udev_version()

Return the version of the udev library. Because the udev library does not
provide a function to get the version number, this function runs the `udevadm`
utility.

Return undef with the error in $@ on failure. Also you can check $! value:
ENOENT (`udevadm` not found) or EACCES (permission denied).

    # simple
    my $udev_version = Udev::FFI::udev_version() or
        die("Can't get udev library version: $@");
    
    # or catch the error
    use Errno qw( :POSIX );
    my $udev_version = Udev::FFI::udev_version();
    unless (defined($udev_version)) {
        if ($!{ENOENT}) {
            # udevadm not found
        }
        elsif ($!{EACCES}) {
            # permission denied
        }
    
        die("Can't get udev library version: $@");
    }

=head1 EXAMPLES

Examples are provided with the Udev::FFI distribution in the "examples"
directory.

=head1 SEE ALSO

libudev

eudev

L<FFI::Platypus> (Write Perl bindings to non-Perl libraries without C or XS)

L<FFI::CheckLib> (Check that a library is available for FFI)

=head1 BUGS AND LIMITATIONS

Udev::FFI supports libudev 171 or newer. Older versions may work too, but it was
not tested.

Please report any bugs through the web interface at
L<https://github.com/Ilya33/udev-ffi/issues>. Patches are always welcome.

=head1 AUTHOR

Ilya Pavlov, E<lt>ilux@cpan.orgE<gt>

Contributors:

Mohammad S Anwar

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017-2025 by Ilya Pavlov

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language
system itself.

=cut
