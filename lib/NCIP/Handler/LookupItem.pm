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

    if ($xmldoc) {
        my ($item_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'ItemIdentifierValue' );
        $item_id = $item_id->textContent();

        my $item = NCIP::Item->new(
            {
                itemid => $item_id,
                ils    => $self->ils,
            }
        );

        my ( $item_data, $error ) = $item->itemdata();

        if ($error) {
            if ($error) {
                my $output = $self->render_output(
                    'problem.tt',
                    {
                        message_type => 'LookupItemResponse',

                        Problem        => 1,
                        ProblemType    => 'BadBarcode',
                        ProblemElement => 'ItemIdentifierValue',
                        processing_error_value => $item_id,
                        ProblemDetail => 'No item with matching barcode found',

                    }
                );
                return $output;
            }

        }

        my $elements = $self->get_item_elements($xmldoc);

        my $output = $self->render_output(
            'response.tt',
            {
                message_type => 'LookupItemResponse',

                item     => $item_data,
                elements => $elements,
            }
        );

        return $output;
    }
}

1;
