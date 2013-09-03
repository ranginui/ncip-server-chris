package NCIPResponder;
use Modern::Perl;
use NCIP;

use FileHandle;

use Apache2::Const -compile => qw(OK :log :http :methods :cmd_how :override);
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use NCIPServer::NCIP;

sub handler {
    my $r = shift;

    return Apache2::Const::HTTP_METHOD_NOT_ALLOWED unless $r->method_number eq Apache2::Const::M_POST;

    my $NCIPConfigFile = $r->dir_config('NCIPConfigFile');

    if (!defined($NCIPConfigFile)) {
        die sprintf "error: There is no NCIPConfigFile defined\n";
    } else {
        if (! (-r $NCIPConfigFile)) {
            die sprintf "error: NCIPConfigFile %s does not exist or is not readable\n", $NCIPConfigFile;
        }
    }

    my $ncip = NCIP->new($NCIPConfigFile);

    $r->content_type('text/html');
    my $tmp_buf;
    my $input_xml;

    while ($r->read($tmp_buf, 1024)) {
        $input_xml .= $tmp_buf;
    }

    my $response_xml = $ncip->process_request($input_xml);

    $r->print($response_xml);
    return Apache2::Const::OK;
}

1;
