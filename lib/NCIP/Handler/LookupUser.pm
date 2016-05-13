package NCIP::Handler::LookupUser;

=head1

  NCIP::Handler::LookupUser

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::User;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {

        # Given our xml document, lets find our userid
        my ($user_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'UserIdentifierValue' );

        my $xpc = $self->xpc();

        unless ($user_id) {

            # We may get a password, username combo instead of userid
            # Need to deal with that also
            my $root = $xmldoc->documentElement();
            my @authtypes =
              $xpc->findnodes( '//ns:AuthenticationInput', $root );

            my $barcode;
            my $pin;    #FIXME: we do nothing with pin authentication

            foreach my $node (@authtypes) {
                my $class =
                  $xpc->findnodes( './ns:AuthenticationInputType', $node );
                my $value =
                  $xpc->findnodes( './ns:AuthenticationInputData', $node );
                if ( $class->[0]->textContent eq 'Barcode Id' ) {
                    $barcode = $value->[0]->textContent;
                }
                elsif ( $class->[0]->textContent eq 'PIN' ) {
                    $pin = $value->[0]->textContent;
                }

            }

            $user_id = $barcode;
        }
        else {
            $user_id = $user_id->textContent();
        }

        # We may get a password, username combo instead of userid
        # Need to deal with that also

        my $user = NCIP::User->new( { userid => $user_id, ils => $self->ils } );
        $user->initialise();
        my $vars;

        #  this bit should be at a lower level

        my ( $from, $to ) = $self->get_agencies($xmldoc);

        # we switch these for the templates
        # because we are responding, to becomes from, from becomes to

        # if we have blank user, we need to return that
        # and can skip looking for elementtypes
        unless ( $user->userdata->{'borrowernumber'} ) {
            my $output = $self->render_output(
                'problem.tt',
                {
                    fromagency  => $to,
                    toagency    => $from,
                    messagetype => 'LookupUserResponse',

                    processingerror        => 1,
                    processingerrortype    => 'LookupUserResponse',
                    processingerrorelement => 'UserIdentifierValue',
                    processing_error_value => $user_id,
                    error_detail =>
                      'No borrower with matching cardnumber found',

                }
            );
            return $output;
        }
        my $elements = $self->get_user_elements($xmldoc);

        my $output = $self->render_output(
            'response.tt',
            {
                fromagency  => $to,
                toagency    => $from,
                messagetype => 'LookupUserResponse',

                elements => $elements,
                user     => $user,
            }
        );
        return $output;

    }
}

1;
