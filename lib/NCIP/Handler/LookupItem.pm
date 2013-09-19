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
our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        # my ($item_id) = $dom->getElementsByTagNameNS( $nsURI, 'ItemId' );
    }
    des = $dom->getElementsByTagNameNS( $nsURI, 'NCIPMessage' );
    return $self->type;
}

1;
