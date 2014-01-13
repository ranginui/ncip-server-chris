package NCIP::Handler::RequestItem;

=head1

  NCIP::Handler::RequestItem

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
          $root->findnodes('RequestItem/UniqueUserId/UserIdentifierValue');
        my $itemid =
          $root->findnodes('RequestItem/UniqueItemId/ItemIdentifierValue');
        my @elements = $root->findnodes('RequestItem/ItemElementType/Value');

        # checkout the item
        my ( $error, $messages ) = $self->ils->request( $userid, $itemid );
        my $vars;
        my $output;
        my $vars->{'barcode'}=$itemid;
        $vars->{'messagetype'} = 'RequestItemResponse';
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
