package NCIP;
use NCIP::Configuration;
use NCIP::Handler;
use Modern::Perl;
use XML::LibXML;
use Try::Tiny;
use Module::Load;
use Template;

use Object::Tiny qw{xmldoc config namespace ils};

our $VERSION           = '0.01';
our $strict_validation = 0;        # move to config file

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
    $self->{config}    = $config;
<<<<<<< HEAD
    $self->{namespace} = $nsURI;
=======
    $self->{namespace} = $config->('NCIP.namespace.value');

    # load the ILS dependent module
    my $module = 'NCIP::ILS::' . $config->('NCIP.ils.value');
    load $module || die "Can not load ILS module $module";
    my $ils = $module->new( name => $config->('NCIP.ils.value') );
    $self->{'ils'} = $ils;
>>>>>>> master
    return bless $self, $class;

}

=head2 process_request()

 my $response = $ncip->process_request($xml);

=cut

sub process_request {
    my $self = shift;
    my $xml  = shift;

    my ($request_type) = $self->handle_initiation($xml);
    unless ($request_type) {

      # We have invalid xml, or we can't figure out what kind of request this is
      # Handle error here
        return;

        #bail out for now
    }
    my $handler = NCIP::Handler->new( $self->namespace(), $request_type );
    return $handler->handle( $self->xmldoc );
}

=head2 handle_initiation

=cut

sub handle_initiation {
    my $self = shift;
    my $xml  = shift;
    my $dom;
    eval { $dom = XML::LibXML->load_xml( string => $xml ); };
    if ($@) {
        warn "Invalid xml, caught error: $@";
    }
    if ($dom) {

        # should check validity with validate at this point
        if ( $strict_validation && !$self->validate($dom) ) {

            # we want strict validation, bail out if dom doesnt validate
            warn " Not valid xml";

            # throw/log error
            return;
        }
        my $request_type = $self->parse_request($dom);

        # do whatever we should do to initiate, then hand back request_type
        if ($request_type) {
            $self->{xmldoc} = $dom;
            return $request_type;
        }
    }
    else {
        warn "We have no DOM";

        return;
    }
}

sub validate {

    # this should perhaps be in it's own module
    my $self = shift;
    my $dom  = shift;
    try {
        $dom->validate();
    }
    catch {
        warn "Bad xml, caught error: $_";
        return;
    };

    # we could validate against the dtd here, might be good?
    # my $dtd = XML::LibXML::Dtd->parse_string($dtd_str);
    # $dom->validate($dtd);
    # perhaps we could check the ncip version and validate that too
    return 1;
}

sub parse_request {
    my $self = shift;
    my $dom  = shift;
    my $nodes =
      $dom->getElementsByTagNameNS( $self->namespace(), 'NCIPMessage' );
    if ($nodes) {
        warn "got nodes";
        my @childnodes = $nodes->[0]->childNodes();
        if ( $childnodes[0] ) {
            return $childnodes[0]->localname();
        }
        else {
            warn "Got a node, but no child node";
            return;
        }
    }
    else {
        warn "Invalid XML";
        return;
    }
    return;
}

sub _error {
    my $self         = shift;
    my $error_detail = shift;
    my $vars;
    $vars->{'error_detail'} = $error_detail;
    my $template = Template->new(
        { INCLUDE_PATH => $self->config->('NCIP.templates.value'), } );
    my $output;
    $template->process( 'problem.tt', $vars, \$output );
    return $output;
}
1;
