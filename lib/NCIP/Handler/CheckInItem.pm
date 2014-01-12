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
        my $itemid =
          $root->findnodes('CheckInItem/UniqueItemId/ItemIdentifierValue');
        my @elements = $root->findnodes('CheckInItem/ItemElementType/Value');

        # checkin the item
        my $checkin = $self->ils->checkin( $itemid );
        my $output;
        my $vars;
        $vars->{'messagetype'} = 'CheckInItemResponse';
        $vars->{'barcode'} = $itemid;
        if ( !$checkin->{success} ) {
            $var->{'processingerror'} = 1;
            $var->{'processingerrortype'} = $checkin->{'messages'};
            $var->{'processingerrorelement'} = 'UniqueItemIdentifier';
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
