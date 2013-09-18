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

use Test::More tests => 5;    # last test to print

use lib 'lib';

use_ok('NCIP');
ok( my $ncip = NCIP->new('t/config_sample'), 'Create new object' );

my $xml = <<'EOT';
<xml>
</xml>
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
