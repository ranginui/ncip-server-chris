package NCIP::Handler::LookupItem;

#
#===============================================================================
#
#         FILE: LookupItem.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 19/09/13 10:52:44
#     REVISION: ---
#===============================================================================

use Modern::Perl;

use NCIP::Handler;
use NCIP::Item;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        # Given our xml document, lets find the itemid
        my ($item_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'ItemIdentifierValue' );
        my $item = NCIP::Item->new( { itemid => $item_id->textContent(), ils => $self->ils} );
        my ($itemdata,$error) = $item->itemdata();
        if ($error){
# handle error here
        }
        warn $item->itemid();
    }
    return $self->type;
}

1;
