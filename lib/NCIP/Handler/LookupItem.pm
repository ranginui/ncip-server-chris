package NCIP::Handler::LookupItem;

=head1

  NCIP::Handler::LookupItem

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::Item;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    my $item;
    if ($xmldoc) {

        # Given our xml document, lets find the itemid
        my ($item_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'ItemIdentifierValue' );
        $item = NCIP::Item->new(
            { itemid => $item_id->textContent(), ils => $self->ils } );
        my ( $itemdata, $error ) = $item->itemdata();
        if ($error) {

            # handle error here
        }
        warn $item->itemid();
    }
    my $vars;
    $vars->{'messagetype'} = 'LookupItemResponse';
    $vars->{'item'}        = $item;
    my $output = $self->render_output( 'response.tt', $vars );
    return $output;
}

1;
