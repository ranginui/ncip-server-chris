package NCIP;
use NCIP::Configuration;
use Modern::Perl;
use XML::LibXML;
use Try::Tiny;

use base qw(Class::Accessor);

our $VERSION = '0.01';

=head1 NAME
  
    NCIP

=head1 SYNOPSIS

    use NCIP;
    my $nicp = NCIP->new($config_dir);

=head1 FUNCTIONS

=cut

sub new {
    my $proto      = shift;
    my $class      = ref $proto || $proto;
    my $config_dir = shift;
    my $self       = {};
    my $config     = NCIP::Configuration->new($config_dir);
    $self->{config} = $config;
    return bless $self, $class;

}

=head2 process_request()

 my $response = $ncip->process_request($xml);

=cut

sub process_request {
    my $self = shift;
    my $xml  = shift;

    my $request_type = $self->handle_initiation($xml);
    unless ($request_type) {

      # We have invalid xml, or we can't figure out what kind of request this is
      # Handle error here
    }

#my $response = "<HTML> <HEAD> <TITLE>Hello There</TITLE> </HEAD> <BODY> <H1>Hello You Big JERK!</H1> Who would take this book seriously if the first eaxample didn't say \"hello world\"?  </BODY> </HTML>";

    #return $response;
    return $request_type;
}

=head2 handle_initiation

=cut

sub handle_initiation {
    my $self = shift;
    my $xml  = shift;
    my $dom;
    try {
        $dom = XML::LibXML->load_xml( string => $xml );
    }
    catch {
        warn "Invalid xml, caught error: $_";
    };
    if ($dom) {

        # should check validity with validate at this point
        my $request_type = $self->parse_request($dom);
        return $request_type;
    }
    else {
        return;
    }
}

sub validate {

    # this should perhaps be in it's own module
    my $self     = shift;
    my $dom      = shift;
    my $validity = $dom->is_valid();

    # we could validate against the dtd here, might be good?
    # my $dtd = XML::LibXML::Dtd->parse_string($dtd_str);
    # my $validity = $dom->is_valid($dtd);
    # perhaps we could check the ncip version and validate that too
    return $validity;
}

sub parse_request {
    my $self  = shift;
    my $dom   = shift;
    my $nodes = $dom->findnodes('/*');
    if ( $nodes->[0]->nodeName() ne 'ns1:NCIPMessage' ) {

        # we don't have a valid ncip message
        # bail out
        warn "bad xml";
    }
    else {
        my @childnodes = $nodes->[0]->childNodes();

        # the second child should be the type of request
        if ( $childnodes[1] && $childnodes[1]->nodeName =~ /ns1\:(.*)/ ) {
            return $1;
        }
        else {
            # just while developing return not found
            return ('Not_found');
        }
    }

    return 0;
}

1;
