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
        my @elements = $root->findnodes('RenewItem/ItemElementType/Value');

        # checkin the item
        my $renewed = $self->ils->renew( $itemid );
        my $output;
        my $vars;
        $vars->{'messagetype'} = 'RenewItemResponse';
        $vars->{'barcode'} = $itemid;
        if ( !$checkin->{success} ) {
            $vars->{'processingerror'} = 1;
            $vars->{'processingerrortype'} = $checkin->{'messages'};
            $vars->{'processingerrorelement'} = 'UniqueItemIdentifier';
            $output = $self->render_output( 'problem.tt', $vars );
        }
        else {

            $vars->{'elements'} = \@elements;
            $vars->{'checkin'}  = $checkin;
            $output = $self->render_output( 'response.tt', $vars );
        }
        return $output;
    }
}

1;
