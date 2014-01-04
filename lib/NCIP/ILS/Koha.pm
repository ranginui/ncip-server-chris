#
#===============================================================================
#
#         FILE: Koha.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 05/11/13 11:14:09
#     REVISION: ---
#===============================================================================
package NCIP::ILS::Koha;

use Modern::Perl;
use Object::Tiny qw{ name };

use C4::Members qw{ GetMemberDetails };
use C4::Circulation qw { AddReturned CanBookBeIssued AddIssue }

  sub itemdata {
    my $self = shift;
    return ( { barcode => '123', title => 'fish' }, undef );
}

sub userdata {
    my $self     = shift;
    my $userid   = shift;
    my $userdata = GetMemberDetails( undef, $userid );
    return $userdata;
}

sub checkin {
    my $self    = shift;
    my $barcode = shift;
    my $result  = AddReturn( $barcode, $branch, $exemptfine, $dropbox );
}

sub checkout {
}

1;
