package NCIP::Item;

use base qw(Class::Accessor);

# Make accessors for the ones that makes sense
NCIP::Item->mk_accessors(qw(itemid ils));

# Call the apppropriate subroutine in the ILS specific code and get the data

sub itemdata {
    my $self     = shift;
    my $ils      = $self->ils;
    my $itemdata = $ils->itemdata( $self->itemid );

    # add anything NCIP specific not handled by the ILS
    # to the itemdata object at this point, if no error
    return $itemdata;
}

1;
