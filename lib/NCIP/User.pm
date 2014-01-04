package NCIP::User;

use base qw(Class::Accessor);

# User Object needs
# Authentication Input
# Block Or Trap
# Date Of Birth
# Name Information
# Previous User Id(s)
# User Address Information
# User Language
# User Privilege
# User Id

# Make accessors for the ones that makes sense
NCIP::User->mk_accessors(qw(userid ils userdata));

sub initialise {
    my $self = shift;
    my $ils  = $self->ils;
    my ( $userdata, $error ) = $ils->userdata( $self->userid );
    $self->{'userdata'} = $userdata;

}

sub authentication {
}

sub previous_userids {
}

sub status {

    # Is the user blocked
    # if so, why
}

1;
