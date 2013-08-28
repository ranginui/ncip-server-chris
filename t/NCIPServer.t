#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('NCIPServer') };

ok(my $server = NCIPServer->new({config_dir => '../t/config_sample'}));

# use Data::Dumper;
# print Dumper $server;

# uncomment this if you want to run the server in test mode
# $server->run();
