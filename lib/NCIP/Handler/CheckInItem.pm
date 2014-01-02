package NCIP::Handler::CheckInItem;

=head1

  NCIP::Handler::CheckInItem

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
          $root->findnodes('CheckInItem/UniqueUserId/UserIdentifierValue');
        my $itemid =
          $root->findnodes('CheckInItem/UniqueItemId/ItemIdentifierValue');
        my @elements = $root->findnodes('CheckInItem/ItemElementType/Value');

        # checkin the item
        my $checkin = $self->ils->checkin( $userid, $itemid );
        my $vars;
        $vars->{'messagetype'} = 'CheckInItemResponse';
        $vars->{'elements'}    = \@elements;
        $vars->{'checkin'}     = $checkin;
        my $output = $self->render_output( 'response.tt', $vars );
        return $output;
    }
}

1;
