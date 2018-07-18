package NCIP::Handler::CancelRequestItem;

=head1

  NCIP::Handler::CancelRequestItem

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::User;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        my $root      = $xmldoc->documentElement();
        my $xpc       = $self->xpc();
        my $userid    = $xpc->findnodes( '//ns:UserIdentifierValue', $root );
        my $requestid = $xpc->findnodes( '//ns:RequestIdentifierValue', $root );

        my $data = $self->ils->cancelrequest($requestid);

        my $elements = $self->get_user_elements($xmldoc);

        # NCIP::ILS::Koha::cancelrequest doesn't return errors
        # no need to deal with them
        return $self->render_output(
            'response.tt',
            {
                message_type => 'CancelRequestItemResponse',
                request_id   => $data->{request_id},
            }
        );
    }
}

1;
