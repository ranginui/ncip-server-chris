package NCIP::Handler::CheckOutItem;

=head1

  NCIP::Handler::CheckOutItem

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        my $root = $xmldoc->documentElement();
        my $xpc  = $self->xpc();

        my $userid   = $xpc->findnodes( '//ns:UserIdentifierValue', $root );
        my $itemid   = $xpc->findnodes( '//ns:ItemIdentifierValue', $root );
        my $date_due = $xpc->findnodes( '//ns:DesiredDateDue',      $root );

        # checkout the item
        my $data = $self->ils->checkout( $userid, $itemid, $date_due );

        my ( $from, $to ) = $self->get_agencies($xmldoc);

        if ( $data->{success} ) {
            my $elements = $self->get_user_elements($xmldoc);
            return $self->render_output(
                'response.tt',
                {
                    from_agency  => $to,
                    to_agency    => $from,
                    barcode      => $itemid,
                    message_type => 'CheckOutItemResponse',
                    userid       => $userid,

                    elements => $elements,
                    datedue  => $data->{date_due},
                }

            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'CheckOutItemResponse',
                    problems     => $data->{problems},
                }
            );
        }
    }
}

1;
