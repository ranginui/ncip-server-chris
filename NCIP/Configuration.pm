#
# Copyright (C) 2013  MnSCU/PALS
# 
# Author: Alan Rykhus
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public
# License as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
# 
# parse-config: Parse an XML-format
# ACS configuration file and build the configuration
# structure.
#

package NCIPServer::NCIP::Configuration;

our $VERSION = 0.02;

use strict;
use warnings;
use XML::Simple qw(:strict);

use NCIPServer::NCIP::Configuration::Account;
use NCIPServer::NCIP::Configuration::Institution;

my $parser = new XML::Simple(
    KeyAttr => {
        login       => '+id',
        institution => '+id',
    },
    GroupTags => {
        accounts     => 'login',
        institutions => 'institution',
    },
    ForceArray => [ 'login', 'institution' ],
);

sub new {
    my ($class, $config_file) = @_;
    my $cfg = $parser->XMLin($config_file);

    foreach my $acct (values %{$cfg->{accounts}}) {
        new NCIPServer::NCIP::Configuration::Account $acct;
    }

    foreach my $inst (values %{$cfg->{institutions}}) {
        new NCIPServer::NCIP::Configuration::Institution $inst;
    }

    return bless $cfg, $class;
}

sub accounts {
    my $self = shift;
    return values %{$self->{accounts}};
}

sub institutions {
    my $self = shift;
    return values %{$self->{institutions}};
}

1;
__END__

=head1 NAME

NCIPServer::NCIP::Configuration - abstraction/accessor for NCIP configs

=head1 SYNOPSIS

use NCIPServer::NCIP::Configuration;
my $config = NCIPServer::NCIP::Configuration->new($ARGV[0]);

foreach my $acct ($config->accounts) {
    print "Found account: '", $acct->id, "', part of '";
    print $acct->institution, "'\n";
}

=cut

