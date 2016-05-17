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
        my $root   = $xmldoc->documentElement();
        my $xpc    = $self->xpc();
        my $itemid = $xpc->find( '//ns:ItemIdentifierValue', $root );
        my ($action)  = $xpc->findnodes( '//ns:RequestedActionType', $root );
        my ($request) = $xpc->findnodes( '//ns:RequestId',           $root );
        my $requestagency = $xpc->find( 'ns:AgencyId', $request );
        my $requestid  = $xpc->find( '//ns:RequestIdentifierValue', $request );
        my $borrowerid = $xpc->find( '//ns:UserIdentifierValue',    $root );

        if ($action) {
            $action = $action->textContent();
        }

        my $iteminfo = $xpc->find( '//ns:ItemOptionalFields', $root );
        my $itemdata = {};

        if ( $iteminfo->[0] ) {

# populate a hashref with bibliographic data, we need this to create an item
# (this could be moved up to Handler.pm eventually as CreateItem will need this also)
            my $bibliographic =
              $xpc->find( '//ns:BibliographicDescription', $iteminfo->[0] );
            my $title = $xpc->find( '//ns:Title', $bibliographic->[0] );
            if ( $title->[0] ) {
                $itemdata->{title} = $title->[0]->textContent();
            }
            my $author = $xpc->find( '//ns:Author', $bibliographic->[0] );
            if ( $author->[0] ) {
                $itemdata->{author} = $author->[0]->textContent();
            }
            my $date =
              $xpc->find( '//ns:PublicationDate', $bibliographic->[0] );
            if ( $date->[0] ) {
                $itemdata->{publicationdate} = $date->[0]->textContent();
            }
            my $publisher = $xpc->find( '//ns:Publisher', $bibliographic->[0] );
            if ( $publisher->[0] ) {
                $itemdata->{publisher} = $publisher->[0]->textContent();
            }
            my $medium = $xpc->find( '//ns:Mediumtype', $bibliographic->[0] );
            if ( $medium->[0] ) {
                $itemdata->{mediumtype} = $medium->[0]->textContent();
            }
        }

        # accept the item
        my $create = 0;
        my ( $from, $to ) = $self->get_agencies($xmldoc);

# Autographics workflow is for an accept item to create the item then do what is in $action
        if ( $from && $from->[0]->textContent() =~ /CPomAG/ ) {
            $create = 1;
        }

        my $pickup_location;
        if ( $to && $to->[0] ) {
            $pickup_location = $to->[0]->textContent();
        }
        else {
            $pickup_location = $xpc->find( '//ns:PickupLocation', $root );
        }

        my $accepted = $self->ils->acceptitem( $itemid->[0]->textContent(),
            $borrowerid, $action, $create, $itemdata, $pickup_location );
        my $output;
        my $vars;

        # we switch these for the templates
        # because we are responding, to becomes from, from becomes to
        $vars->{'from_agency'} = $to;
        $vars->{'to_agency'}   = $from;

        $vars->{'message_type'} = 'AcceptItemResponse';
        $vars->{'barcode'}     = $itemid;
        if ( !$accepted->{success} ) {
            $vars->{'Problem'}        = 1;
            $vars->{'ProblemType'}    = $accepted->{'messages'};
            $vars->{'ProblemElement'} = 'UniqueItemIdentifier';
            $output = $self->render_output( 'problem.tt', $vars );
        }
        else {
            my $elements = $self->get_user_elements($xmldoc);
            $vars->{'requestagency'} = $requestagency;
            $vars->{'requestid'}     = $requestid;
            $vars->{'newbarcode'}    = $accepted->{'newbarcode'} || $itemid;
            $vars->{'elements'}      = $elements;
            $vars->{'accept'}        = $accepted;
            $output = $self->render_output( 'response.tt', $vars );
        }
        return $output;
    }
}

1;
