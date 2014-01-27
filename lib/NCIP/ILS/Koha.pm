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
use C4::Context;

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
    my $self       = shift;
    my $barcode    = shift;
    my $branch     = shift;
    my $exemptfine = undef;
    my $dropbox    = undef;
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
    my $self     = shift;
    my $userid   = shift;
    my $barcode  = shift;
    my $borrower = GetMemberDetails( undef, $userid );
    my $error;
    my $confirm;
     my ($usernum, $userid, $usercnum, $userfirstname, $usersurname, $userbranch, $branchname, $userflags, $emailaddress, $branchprinter, $persona)= @_;
    my @USERENV = (
    1,
    'test',
    'MASTERTEST',
    'Test',
    'Test',
    'AS', #branchcode need to set this properly
    'Auckland',
    0,
    );

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv ( @USERENV );


   if ($borrower) {

        ( $error, $confirm ) = CanBookBeIssued( $borrower, $barcode );

  #( $issuingimpossible, $needsconfirmation ) =  CanBookBeIssued( $borrower,
  #                      $barcode, $duedatespec, $inprocess, $ignore_reserves );
        if (%$error) {

            # Can't issue item, return error hash
            return ( 1, $error );
        }
        elsif (%$confirm) {
            return ( 1, $confirm );
        }
        else {
            my $datedue = AddIssue( $borrower, $barcode );
            return (0, undef, $datedue);    #successfully issued
        }
    }
    else {
        $error->{'badborrower'} = 1;
        return ( 1, $error );
    }
}

1;
