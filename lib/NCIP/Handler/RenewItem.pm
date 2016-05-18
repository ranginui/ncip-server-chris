package NCIP::Handler::RenewItem;

=head1

  NCIP::Handler::RenewItem

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
        my $itemid =
          $root->findnodes('RenewItem/UniqueItemId/ItemIdentifierValue');

        my $data = $self->ils->renew($itemid);

        if ( $data->{success} ) {
            my @elements = $root->findnodes('RenewItem/ItemElementType/Value');
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'RenewItemResponse',
                    barcode      => $itemid,
                    elements     => \@elements,
                    data         => $data,
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'RenewItemResponse',
                    problems     => $data->{problems},
                }
            );
        }
    }
}

1;
