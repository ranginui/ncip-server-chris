package NCIP;
use NCIP::Configuration;
use Modern::Perl;
use base qw(Class::Accessor);

our $VERSION='0.01';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my $config_dir = shift;
    my $self = {};
    my $config = NCIP::Configuration->new($config_dir);
    $self->{config} = $config;
    return bless $self, $class;

}

sub process_request {
    my $self = shift;
    my $xml = shift;
    
    my $request_type = $self->handle_initiation($xml);
    my $response = "<HTML> <HEAD> <TITLE>Hello There</TITLE> </HEAD> <BODY> <H1>Hello You Big JERK!</H1> Who would take this book seriously if the first eaxample didn't say \"hello world\"?  </BODY> </HTML>";

    return $response;
}

sub handle_initiation {
    my $self = shift;
    my $xml = shift;

    return('lookup_item');
}

1;
