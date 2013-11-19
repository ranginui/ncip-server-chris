package NCIP::Handler::LookupUser;

=head1

  NCIP::Handler::LookupUser

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
        # Given our xml document, lets find the itemid
        my ($user_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'UserIdentifierValue' );
          warn $user_id->textContent();
#        my $item = NCIP::User->new( { itemid => $user_id->textContent(), ils => $self->ils} );
#        my ($itemdata,$error) = $item->itemdata();
#       if ($error){
# handle error here
#        }
#        warn $user->itemid();
    }
    return $self->type;
}

1;
