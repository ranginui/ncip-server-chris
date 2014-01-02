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
        my $checkout = $self->ils->checkout( $userid, $itemid );
        my $vars;
        $vars->{'messagetype'} = 'CheckOutItemResponse';
        $vars->{'elements'}    = \@elements;
        $vars->{'checkout'}    = $checkout;
        my $output = $self->render_output( 'response.tt', $vars );
        return $output;
    }
}

1;
