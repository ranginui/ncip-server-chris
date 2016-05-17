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

use MARC::Record;
use MARC::Field;

use C4::Members qw{ GetMemberDetails IsMemberBlocked };
use C4::Circulation qw{ AddReturn CanBookBeIssued AddIssue GetTransfers };
use C4::Context;
use C4::Items qw{ GetItem };
use C4::Reserves
  qw{ CanBookBeReserved AddReserve GetReservesFromItemnumber CancelReserve GetReservesFromBiblionumber GetReserveStatus };
use C4::Biblio qw{ AddBiblio GetMarcFromKohaField GetBiblioData GetMarcBiblio };
use C4::Barcodes::ValueBuilder;
use C4::Items qw{AddItem};
use Koha::Database;
use Koha::Holds;

sub itemdata {
    my $self    = shift;
    my $barcode = shift;

    my $item = GetItem( undef, $barcode );

    if ($item) {

        my $biblio = GetBiblioData( $item->{itemnumber} );
        $item->{biblio} = $biblio;

        my $record = GetMarcBiblio( $item->{biblionumber} );
        $item->{record} = $record;

        my $itemtype = Koha::Database->new()->schema()->resultset('Itemtype')
          ->find( $item->{itype} );
        $item->{itemtype} = $itemtype;

        my $hold = GetReserveStatus( $item->{itemnumber} );
        $item->{hold} = $hold;

        my @holds = Koha::Holds->search( { $item->{biblionumber} } );
        $item->{holds} = \@holds;

        my @transfers = GetTransfers( $item->{itemnumber} );
        $item->{transfers} = \@transfers;

        return ( $item, undef );
    }
    else {
        return ( undef, 1 );    # item not found error
    }
}

sub userdata {
    my $self     = shift;
    my $userid   = shift;
    my $userdata = GetMemberDetails( undef, $userid );

    my ( $block_status, $count ) =
      IsMemberBlocked( $userdata->{borrowernumber} );
    $userdata->{restricted} = $block_status;

    return $userdata;
}

sub userenv {    #FIXME: This really needs to be in a config file
    my $self    = shift;
    my $branch  = shift || 'AS';
    my @USERENV = (
        undef,               #set_userenv shifts the first var for no reason
        312,                 #borrowernumber
        'NCIP',              #userid
        '24535000002009',    #cardnumber
        'NCIP',              #firstname
        'User',              #surname
        $branch,             #branchcode need to set this properly
        'Auckland',          #branchname
        1,                   #userflags
    );

    C4::Context->_new_userenv('DUMMY_SESSION_ID');
    C4::Context::set_userenv(@USERENV);
}

sub checkin {
    my $self        = shift;
    my $barcode     = shift;
    my $branch      = shift;
    my $exempt_fine = undef;
    my $dropbox     = undef;

    $self->userenv();

    unless ($branch) {
        my $item = GetItem( undef, $barcode );
        $branch = $item->{holdingbranch};
    }

    my ( $success, $messages, $issue, $borrower ) =
      AddReturn( $barcode, $branch, $exempt_fine, $dropbox );

    $success ||= 1 if $messages->{LocalUse};
    $success &&= 0 if $messages->{NotIssued};

    my @problems;

    push(
        @problems,
        {
            problem_type    => 'Item Not Checked Out',
            problem_element => 'UniqueItemIdentifier',
            problem_value   => $barcode,
            problem_detail =>
              'There is no record of the check out of the item.',
        }
    ) if $messages->{NotIssued};

    push(
        @problems,
        {
            problem_type    => 'Unknown Item',
            problem_element => 'UniqueItemIdentifier',
            problem_value   => $barcode,
            problem_detail  => 'Item is not known.',
        }
    ) if $messages->{BadBarcode};

    my $result = {
        success   => $success,
        problems  => \@problems,
        item_data => $issue,
        borrower  => $borrower
    };

    return $result;
}

=head2 checkout

{ success => $success, problems => \@problems, date_due => $date_due } =
  $ils->checkout( $userid, $itemid, $date_due );

=cut

sub checkout {
    my $self     = shift;
    my $userid   = shift;
    my $barcode  = shift;
    my $date_due = shift;

    my $borrower = GetMemberDetails( undef, $userid );
    my $item = GetItem( undef, $barcode );

    $self->userenv( $item->{holdingbranch} );

    if ($borrower) {
        my ( $error, $confirm ) =
          CanBookBeIssued( $borrower, $barcode, $date_due );

        my $reasons = { %$error, %$confirm };

        if (%$reasons) {
            my @problems;

            push(
                @problems,
                {
                    problem_type    => 'Unknown Item',
                    problem_detail  => 'Item is not known.',
                    problem_element => 'ItemIdentifierValue',
                    problem_value   => $barcode,
                }
            ) if $reasons->{UNKNOWN_BARCODE};

            push(
                @problems,
                {
                    problem_type => 'User Ineligible To Che ck Out This Item',
                    problem_detail =>
                      'Item is alredy checked out to this User.',
                    problem_element => 'ItemIdentifierValue',
                    problem_value   => $barcode,
                    problem_element => 'UserIdentifierValue',
                    problem_value   => $userid,
                }
            ) if $reasons->{BIBLIO_ALREADY_ISSUED};

            push(
                @problems,
                {
                    problem_type    => 'Invalid Date',
                    problem_detail  => 'Item is not known.',
                    problem_element => 'DesiredDateDue',
                    problem_value   => $date_due,
                }
            ) if $reasons->{INVALID_DATE} || $reasons->{INVALID_DATE};

            push(
                @problems,
                {
                    problem_type    => 'User Blocked',
                    problem_element => 'UserIdentifierValue',
                    problem_value   => $userid,
                    problem_detail  => $reasons->{GNA} ? 'Gone no address'
                    : $reasons->{LOST}               ? 'Card lost'
                    : $reasons->{DBARRED}            ? 'User restricted'
                    : $reasons->{EXPIRED}            ? 'User expired'
                    : $reasons->{DEBT}               ? 'User has debt'
                    : $reasons->{USERBLOCKEDOVERDUE} ? 'User has overdue items'
                    : $reasons->{USERBLOCKEDNOENDDATE} ? 'User restricted'
                    : $reasons->{AGE_RESTRICTION}      ? 'Age restriction'
                    :                                    'Reason unkown'
                }
              )
              if $reasons->{GNA}
              || $reasons->{LOST}
              || $reasons->{DBARRED}
              || $reasons->{EXPIRED}
              || $reasons->{DEBT}
              || $reasons->{USERBLOCKEDOVERDUE}
              || $reasons->{USERBLOCKEDOVERDUEDATE}
              || $reasons->{AGE_RESTRICTION};

            push(
                @problems,
                {
                    problem_type => 'Maximum Check Outs Exceeded',
                    problem_detail =>
                      'Check out cannot proceed because the User '
                      . 'already has the maximum number of items checked out.',
                    problem_element => 'UserIdentifierValue',
                    problem_value   => $userid,
                }
            ) if $reasons->{TOO_MANY};

            push(
                @problems,
                {
                    problem_type   => 'Item Does Not Circulate',
                    problem_detail => 'Check out of Item cannot proceed '
                      . 'because the Item is non-circulating.',
                    problem_element => 'ItemIdentifierValue',
                    problem_value   => $barcode,
                }
            ) if $reasons->{NOT_FOR_LOAN} || $reasons->{NOT_FOR_LOAN_FORCING};

            push(
                @problems,
                {
                    problem_type =>
                      'Check Out Not Allowed - Item Has Outstanding Requests',
                    problem_detail => 'Check out of Item cannot proceed '
                      . 'because the Item has outstanding requests.',
                    problem_element => 'ItemIdentifierValue',
                    problem_value   => $barcode,
                }
            ) if $reasons->{RESERVE_WAITING} || $reasons->{RESERVED};

            push(
                @problems,
                {
                    problem_type   => 'Resource Cannot Be Provided',
                    problem_detail => 'Check out cannot proceed because '
                      . 'the desired resource cannot be provided',
                    problem_element => 'ItemIdentifierValue',
                    problem_value   => $barcode,
                }
              )
              if $reasons->{WTHDRAWN}
              || $reasons->{RESTRICTED}
              || $reasons->{ITEM_LOST}
              || $reasons->{ITEM_LOST}
              || $reasons->{BORRNOTSAMEBRANCH}
              || $reasons->{HIGHHOLDS}
              || $reasons->{NO_RENEWAL_FOR_ONSITE_CHECKOUTS}    #FIXME: Should
              || $reasons->{NO_MORE_RENEWALS}                   #FIXME have
              || $reasons->{RENEW_ISSUE};    #FIXME different error

            return { success => 0, problems => \@problems };
        }
        else {
            my $issue = AddIssue( $borrower, $barcode, $date_due );
            $date_due = $issue->date_due();
            $date_due =~ s/ /T/;
            return { success => 1, date_due => $date_due };
        }
    }
    else {
        my @problems;
        push(
            @problems,
            {
                problem_type    => 'Unknown User',
                problem_detail  => 'User is not known',
                problem_element => 'UserIdentifierValue',
                problem_value   => $userid,
            }
        );
        return { success => 0, problems => \@problems };
    }
}

sub renew {
    my $self     = shift;
    my $barcode  = shift;
    my $userid   = shift;
    my $borrower = GetMemberDetails( undef, $userid );
    if ($borrower) {
        my $datedue = AddRenewal( $barcode, $borrower->{'borrowernumber'} );
        my $result = {
            success => 1,
            datedue => $datedue
        };
        return $result;

    }
    else {
        #handle stuff here
    }
}

sub request {
    my $self         = shift;
    my $cardnumber   = shift;
    my $barcode      = shift;
    my $biblionumber = shift;
    my $type         = shift;
    my $branchcode   = shift;

    my $borrower = GetMemberDetails( undef, $cardnumber );

    unless ($borrower) {
        return { success => 0, messages => { 'BORROWER_NOT_FOUND' => 1 } };
    }

    #FIXME: Maybe this should be configurable?
    # If no branch is given, fall back to patron home library
    $branchcode ||= q{};
    $branchcode =~ s/^\s+|\s+$//g;
    $branchcode ||= $borrower->{branchcode};
    unless ($branchcode) {
        return { success => 0, messages => { 'BRANCH_NOT_FOUND' => 1 } };
    }

    my $itemdata;
    if ($barcode) {
        $itemdata = GetItem( undef, $barcode );
    }
    else {
        if ( $type eq 'SYSNUMBER' ) {
            $itemdata = GetBiblioData($biblionumber);
        }
        elsif ( $type eq 'ISBN' ) {

            #deal with this
            die("Request by ISBN not yet implemented");
        }
    }

    unless ($itemdata) {
        return { success => 0, messages => {'ITEM_NOT_FOUND'} };
    }

    $self->userenv();

    if (
        CanBookBeReserved(
            $borrower->{borrowernumber},
            $itemdata->{biblionumber}
        )
      )
    {
        my $biblioitemnumber = $itemdata->{biblionumber};

        # Add reserve here
        my $request_id = AddReserve(
            $branchcode, $borrower->{borrowernumber},
            $itemdata->{biblionumber}, [$biblioitemnumber],
            1,     undef,
            undef, 'Placed By ILL',
            '',    $itemdata->{'itemnumber'} || undef,
            undef
        );

        if ($request_id) {
            return {
                success  => 1,
                messages => {
                    request_id => $request_id
                }
            };
        }
        else {
            return {
                success  => 0,
                messages => {
                    'DUPLICATE_REQUEST' => 1,
                }
            };

        }
    }
    else {
        return {
            success  => 0,
            messages => {
                CANNOT_REQUEST => 1
            }
        };
    }
}

sub cancelrequest {
    my $self      = shift;
    my $requestid = shift;

    CancelReserve( { reserve_id => $requestid } );

    return {
        success  => 1,
        messages => {
            request_id => $requestid
        }
    };
}

sub acceptitem {
    my $self    = shift || die "Not called as a method, we must bail out";
    my $barcode = shift || die "No barcode passed can not continue";
    my $user    = shift;
    my $action  = shift;
    my $create  = shift;
    my $iteminfo   = shift;
    my $branchcode = shift;

    $branchcode =~ s/^\s+|\s+$//g;
    $branchcode = "$branchcode";    # Convert XML::LibXML::NodeList to string
    my $result;

    $self->userenv();               # set userenvironment
    my ( $biblionumber, $biblioitemnumber );
    if ($create) {
        my $record;
        my $frameworkcode = 'FA';    # we should get this from config

        # we must make the item first
        # Autographics workflow is to make the item each time
        if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {

            # TODO
        }
        elsif ( C4::Context->preference('marcflavour') eq 'NORMARC' ) {

            #TODO
        }
        else {
            # MARC21
            # create a marc record
            $record = MARC::Record->new();
            $record->leader('     nac  22     1u 4500');
            $record->insert_fields_ordered(
                MARC::Field->new(
                    '100', '1', '0', 'a' => $iteminfo->{author}
                ),
                MARC::Field->new(
                    '245', '1', '0', 'a' => $iteminfo->{title}
                ),
                MARC::Field->new(
                    '260', '1', '0',
                    'b' => $iteminfo->{publisher},
                    'c' => $iteminfo->{publicationdate}
                ),
                MARC::Field->new(
                    '942', '1', '0', 'c' => $iteminfo->{mediumtype}
                )
            );

        }

        ( $biblionumber, $biblioitemnumber ) =
          AddBiblio( $record, $frameworkcode );
        my $itemnumber;
        $barcode = 'ILL' . $biblionumber . time unless $barcode;
        my $item = {
            'barcode'       => $barcode,
            'holdingbranch' => $branchcode,
            'homebranch'    => $branchcode
        };
        ( $biblionumber, $biblioitemnumber, $itemnumber ) =
          AddItem( $item, $biblionumber );
    }

    # find hold and get branch for that, check in there
    my $itemdata = GetItem( undef, $barcode );

    my ( $reservedate, $borrowernumber, $branchcode2, $reserve_id, $wait ) =
      GetReservesFromItemnumber( $itemdata->{'itemnumber'} );

    # now we have to check the requested action
    if ( $action =~ /^Hold For Pickup And Notify/ ) {
        unless ($reserve_id) {

            # no reserve, place one
            if ($user) {
                my $borrower = GetMemberDetails( undef, $user );
                if ($borrower) {
                    AddReserve(
                        $branchcode,
                        $borrower->{'borrowernumber'},
                        $itemdata->{biblionumber},
                        [$biblioitemnumber],
                        1,
                        undef,
                        undef,
                        'Placed By ILL',
                        '',
                        $itemdata->{'itemnumber'},
                        undef
                    );
                }

                else {
                    $result =
                      { success => 0, messages => { NO_BORROWER => 1 } };
                    return $result;
                }
            }
            else {
                $result =
                  { success => 0, messages => { NO_HOLD_BORROWER => 1 } };
                return $result;
            }
        }
    }
    else {
        unless ($reserve_id) {
            $result = { success => 0, messages => { NO_HOLD => 1 } };
            return $result;
        }
    }

    my ( $success, $messages, $issue, $borrower ) =
      AddReturn( $barcode, $branchcode, undef, undef );

    if ( $messages->{'NotIssued'} ) {
        $success = 1
          ; # we do this because we are only doing the return to trigger the reserve
    }

    $result = {
        success    => $success,
        messages   => $messages,
        item_data  => $issue,
        borrower   => $borrower,
        newbarcode => $barcode
    };

    return $result;
}
1;
