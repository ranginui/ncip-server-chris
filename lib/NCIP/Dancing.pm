package NCIP::Dancing;

use Dancer ':syntax';
use FindBin;
use Cwd qw/realpath/;

our $VERSION = '0.1';

use XML::Tidy::Tiny qw(xml_tidy);

use NCIP;

any [ 'get', 'post' ] => '/' => sub {
    my $appdir = realpath( "$FindBin::Bin/..");
    #FIXME: Why are we always looking in t for the config, even for production?
    my $ncip = NCIP->new("$appdir/t/config_sample");
    my $xml  = param 'xml';
    if ( request->is_post ) {
        $xml = request->body;
    }
    my $content = $ncip->process_request($xml, config);


    my $xml = template 'main', { content => $content, ncip_version => $ncip->{ncip_protocol_version} };
    $xml = xml_tidy($xml);
    warn "XML RESPONSE:*$xml*";
    return $xml;
};

true;
