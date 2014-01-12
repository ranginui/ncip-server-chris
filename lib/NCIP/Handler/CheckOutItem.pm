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
        my $userid =
          $root->findnodes('CheckOutItem/UniqueUserId/UserIdentifierValue');
        my $itemid =
          $root->findnodes('CheckOutItem/UniqueItemId/ItemIdentifierValue');
        my @elements = $root->findnodes('CheckOutItem/ItemElementType/Value');

        # checkout the item
        my ( $error, $messages ) = $self->ils->checkout( $userid, $itemid );
        my $vars;
        my $output;
        my $vars->{'barcode'}=$itemid;
        $vars->{'messagetype'} = 'CheckOutItemResponse';
        if ($error) {
            $vars->{'processingerror'}        = 1;
            $vars->{'processingerrortype'}    = $messages;
            $vars->{'processingerrorelement'} = 'UniqueItemIdentifier';
            $output = $self->render_output( 'problem.tt', $vars );
        }
        else {
            $vars->{'elements'} = \@elements;

            $output = $self->render_output( 'response.tt', $vars );
        }
        return $output;
    }
}

1;
