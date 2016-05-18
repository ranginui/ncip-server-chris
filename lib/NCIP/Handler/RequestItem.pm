package NCIP::Handler::RequestItem;

=head1

  NCIP::Handler::RequestItem

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
        my $xpc  = XML::LibXML::XPathContext->new;
        $xpc->registerNs( 'ns', $self->namespace() );

        my ($userid) = $xpc->findnodes( '//ns:UserIdentifierValue', $root );
        $userid = $userid->textContent() if $userid;

        my ($itemid) = $xpc->findnodes( '//ns:ItemIdentifierValue', $root );
        $itemid = $itemid->textContent() if $itemid;

        my ($biblio_id) =
          $xpc->findnodes( '//ns:BibliographicRecordIdentifier', $root );
        my $biblionumber = $biblio_id->textContent() if $biblio_id;

        my ($biblio_type) =
          $xpc->findnodes( '//ns:BibliographicItemIdentifierCode', $root );
        my $type = 'SYSNUMBER';
        $type = $biblio_type->textContent() if $biblio_type;

        my ( $from, $to ) = $self->get_agencies($xmldoc);

        my $branchcode = $to->[0]->textContent() if $to;

        my $data =
          $self->ils->request( $userid, $itemid, $biblionumber, $type,
            $branchcode );

        if ( $data->{success} ) {
            my $elements = $self->get_user_elements($xmldoc);
            return $self->render_output(
                'response.tt',
                {
                    message_type => 'RequestItemResponse',
                    from_agency  => $to,
                    to_agency    => $from,
                    barcode      => $itemid,
                    request_id   => $data->{request_id},
                    elements     => $elements,
                }
            );
        }
        else {
            return $self->render_output(
                'problem.tt',
                {
                    message_type => 'RequestItemResponse',
                    problems     => $data->{problems},
                }

            );
        }
    }
}

1;
