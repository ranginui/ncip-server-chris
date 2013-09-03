package NCIP;
use NCIP::Configuration;
use Modern::Perl;


use FileHandle;

sub new {
    my $self = shift;
    my $config_file = shift;

    my $config = NCIP::Configuration->new($config_file);
    return bless $config, $self;

}

sub process_request {
    my $self = shift;
    my $xml = shift;

    my $response = "<HTML> <HEAD> <TITLE>Hello There</TITLE> </HEAD> <BODY> <H1>Hello You Big JERK!</H1> Who would take this book seriously if the first eaxample didn't say \"hello world\"?  </BODY> </HTML>";

    return $response;
}

1;
