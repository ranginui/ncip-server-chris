#
#===============================================================================
#
#         FILE: NCIP.t
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 18/09/13 09:59:01
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use File::Slurp;

use Test::More tests => 7;    # last test to print

use lib 'lib';

use_ok('NCIP');
ok( my $ncip = NCIP->new('t/config_sample'), 'Create new object' );

my $xml = <<'EOT';
<?xml version="1.0" encoding="UTF-8"?>
<ns1:NCIPMessage
  ns1:version="http://www.niso.org/schemas/ncip/v2_0/imp1/xsd/ncip_v2_0.xsd" xmlns:ns1="http://www.niso.org/2008/ncip">
</ns1:NCIPMessage>
EOT

ok( my $response = $ncip->process_request($xml), 'Process a request' );

my $xmlbad = <<'EOT';
<xml>
this is bad
<xml>
</xml>
EOT

# handle_initiation is called as part of the process_request, but best to test
# anyway
ok( !$ncip->handle_initiation($xmlbad), 'Bad xml' );
ok( $ncip->handle_initiation($xml),     'Good XML' );

my $lookupitem = read_file('t/sample_data/LookupItem.xml');

ok( my $response = $ncip->process_request($lookupitem), 'Try looking up an item');
is ($response, 'LookupItem', 'We got lookupitem');
