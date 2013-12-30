package NCIP::Dancing;
use Dancer ':syntax';

our $VERSION = '0.1';

use NCIP;


any ['get', 'post'] => '/' => sub {
    my $ncip = NCIP->new('t/config_sample');
    my $xml = param 'xml';
    warn $xml if $xml;
    my $content = $ncip->process_request($xml);
  #  warn $content;
    template 'main', { content => $content };

  #  warn "what";
};

true;
