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



__END__



# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Udev::FFI - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Udev::FFI;
  blah blah blah

=head1 DESCRIPTION

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

Ilya Pavlov, E<lt>iluxz@mail.ru<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Ilya Pavlov


=cut