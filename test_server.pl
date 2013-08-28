#!/usr/bin/perl 
#===============================================================================
#
#         FILE: test_server.pl
#
#        USAGE: ./test_server.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 28/08/13 14:12:51
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use lib "lib";

use NCIPServer;

my $server = NCIPServer->new( { config_dir => 't/config_sample' } );
$server->run();
