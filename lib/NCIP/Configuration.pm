package NCIP::Configuration;
#
#===============================================================================
#
#         FILE: Configuration.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Chris Cormack (rangi), chrisc@catalyst.net.nz
# ORGANIZATION: Koha Development Team
#      VERSION: 1.0
#      CREATED: 28/08/13 10:16:55
#     REVISION: ---
#===============================================================================

=head1 NAME
  
  NCIP::Configuration

=head1 SYNOPSIS

  use NCIP::Configuration;
  my $config = NCIP::Configuration->new($config_dir);

=cut

use Modern::Perl;

use base qw(Config::Merge);

1;

