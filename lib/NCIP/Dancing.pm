package NCIP::Dancing;
use Dancer ':syntax';

our $VERSION = '0.1';

use NCIP;


any ['get', 'post'] => '/' => sub {
    my $ncip = NCIP->new('t/config_sample');
    my $xml = param 'xml';
    my $content = $ncip->process_request($xml);
    template 'main', { content => $content };
};

true;
