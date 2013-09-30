package NCIP::Item;

use base qw(Class::Accessor);

# Make accessors for the ones that makes sense
NCIP::Item->mk_accessors(qw(itemid));

1;
