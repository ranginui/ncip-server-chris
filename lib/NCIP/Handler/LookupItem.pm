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

        my $item_data = $item->itemdata();

        if ($item_data) {
            my $elements = $self->get_item_elements($xmldoc);
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'LookupItemResponse',
                    item         => $item_data,
                    elements     => $elements,
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'LookupItemResponse',
                    problems     => [
                        {
                            problem_type    => 'Unknown Item',
                            problem_detail  => 'Item is not known.',
                            problem_element => 'ItemIdentifierValue',
                            problem_value   => $item_id,
                        }
                    ]
                }
            );
        }
    }
}

1;
