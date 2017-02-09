package NCIP::Handler::AcceptItem;

=head1

  NCIP::Handler::AcceptItem

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
        my $xpc  = $self->xpc();

        my $config = $self->{config}->{koha};

        my ( $itemid, $action, $request, $request_agency, $request_id, $user_id, $item_info );
        if ( $self->{ncip_version} == 1 ) {
            $itemid = $xpc->find( '//ItemIdentifierValue', $root );
            ($action) = $xpc->find( '//RequestedActionType//Value', $root );
            $request_agency =
              $xpc->find( '//FromAgencyId/UniqueAgencyId/Value', $root );
            $request_id = $xpc->find( '//RequestIdentifierValue', $root );
            $user_id    = $xpc->find( '//UserIdentifierValue',    $root );

            $item_info = $xpc->find( '//ItemOptionalFields', $root );
        }
        else {    # $version == 2
            $itemid = $xpc->find( '//ns:ItemIdentifierValue', $root );
            ($action)  = $xpc->findnodes( '//ns:RequestedActionType', $root );
            ($request) = $xpc->findnodes( '//ns:RequestId',           $root );
            $request_agency = $xpc->find( 'ns:AgencyId', $request );
            $request_id = $xpc->find( '//ns:RequestIdentifierValue', $request );
            $user_id    = $xpc->find( '//ns:UserIdentifierValue',    $root );

            if ($action) {
                $action = $action->textContent();
            }

            $item_info = $xpc->find( '//ns:ItemOptionalFields', $root );
        }

        my $itemdata = {};

        if ( $item_info->[0] ) {

            # populate a hashref with bibliographic data,
            # we need this to create an item
            # (this could be moved up to Handler.pm
            # eventually as CreateItem will need this also)
            my $bibliographic =
              $xpc->find( '//BibliographicDescription', $item_info->[0] );
            my $title = $xpc->find( '//Title', $bibliographic->[0] );
            if ( $title->[0] ) {
                $itemdata->{title} = $title->[0]->textContent();
            }
            my $author = $xpc->find( '//Author', $bibliographic->[0] );
            if ( $author->[0] ) {
                $itemdata->{author} = $author->[0]->textContent();
            }
            my $date = $xpc->find( '//PublicationDate', $bibliographic->[0] );
            if ( $date->[0] ) {
                $itemdata->{publicationdate} = $date->[0]->textContent();
            }
            my $publisher = $xpc->find( '//Publisher', $bibliographic->[0] );
            if ( $publisher->[0] ) {
                $itemdata->{publisher} = $publisher->[0]->textContent();
            }
            my $medium = $xpc->find( '//Mediumtype', $bibliographic->[0] );
            if ( $medium->[0] ) {
                $itemdata->{mediumtype} = $medium->[0]->textContent();
            }
        }

        # accept the item
        my ( $from, $to ) =
          $self->get_agencies( $xmldoc, $self->{ncip_version} );

        # Autographics workflow is for an accept item i
        # to create the item then do what is in $action
        my $create = 0;
        if ( $from && $from =~ /CPomAG/ ) {
            $create = 1;
        }
        $create = 1;    # Same for Relais, just always create for now

        my $pickup_location = $to;
        $pickup_location ||= $xpc->find( '//PickupLocation', $root );

        my $data = $self->ils->acceptitem( $itemid, $user_id, $action, $create, $itemdata, $pickup_location, $config );

        my $output;
        my $vars;

        # we switch these for the templates
        # because we are responding, to becomes from, from becomes to
        if ( !$data->{success} ) {
            $output = $self->render_output(
                'problem.tt',
                {
                    message_type => 'AcceptItemResponse',
                    problems     => $data->{problems},
                },
                $self->{ncip_version},
            );
        }
        else {
            my $elements = $self->get_user_elements($xmldoc);
            $output = $self->render_output(
                'response.tt',
                {
                    from_agency    => $to,
                    to_agency      => $from,
                    message_type   => 'AcceptItemResponse',
                    barcode        => $itemid,
                    request_agency => $request_agency,
                    requestid      => $request_id,
                    newbarcode     => $data->{'newbarcode'} || $itemid,
                    elements       => $elements,
                    accept         => $data,
                },
                $self->{ncip_version},
            );
        }
        return $output;
    }
}

1;
