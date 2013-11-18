package NCIP::Handler;
#
#===============================================================================
#
#         FILE: Hander.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 19/09/13 10:43:14
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use Object::Tiny qw{ type namespace ils };

use NCIP::Handler::LookupItem;

sub new {
    my $class    = shift;
    my $params   = shift;
    my $subclass = __PACKAGE__ . "::" . $params->{type};
    my $self     = bless {
        type      => $params->{type},
        namespace => $params->{namespace},
        ils       => $params->{ils}
    }, $subclass;
    return $self;
}

1;
