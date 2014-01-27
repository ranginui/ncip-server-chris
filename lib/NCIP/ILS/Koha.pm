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
use C4::Circulation qw { AddReturn CanBookBeIssued AddIssue };

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
    my $branch = shift;
    my $exemptfine = undef;
    my $dropbox = undef;
    my ( $success, $messages, $issue, $borrower ) =
      AddReturn( $barcode, $branch, $exemptfine, $dropbox );
    my $result = {
        success         => $success,
        messages        => $messages,
        iteminformation => $issue,
        borrower        => $borrower
    };
    return $result;
}

sub checkout {
    my $self    = shift;
    my $userid  = shift;
    my $barcode = shift;
    my ( $error, $confirm ) = CanBookBeIssued( $userid, $barcode );

  #( $issuingimpossible, $needsconfirmation ) =  CanBookBeIssued( $borrower,
  #                      $barcode, $duedatespec, $inprocess, $ignore_reserves );
    if ( $error || $confirm ) {

        # Can't issue item, return error hash
        return ( 1, $error || $confirm );
    }
    else {
        AddIssue( $userid, $barcode );
        return (0);    #successfully issued
    }
}

1;
