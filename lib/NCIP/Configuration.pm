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

use NCIP::Configuration::Service;
use base qw(Config::Merge);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    my @services;

    # we might have a few services set them up safely
    if ( ref( $self->('NCIP.listeners.service') ) eq 'ARRAY' ) {
        @services = $self->('NCIP.listeners.service');
    }
    else {
        @services = ( $self->('NCIP.listeners')->{'service'} );
    }
    my %listeners;
    foreach my $service (@services) {
        my $serv_object = NCIP::Configuration::Service->new($service);
        $listeners{ lc $service->{'port'} } = $serv_object;
    }
    $self->{'listeners'} = \%listeners;
    return $self;
}

sub find_service {
    my ( $self, $sockaddr, $port, $proto ) = @_;
    my $portstr;
    foreach my $addr ( '', '*:', "$sockaddr:" ) {
        $portstr = sprintf( "%s%s/%s", $addr, $port, lc $proto );
        Sys::Syslog::syslog( "LOG_DEBUG",
            "Configuration::find_service: Trying $portstr" );
        last if ( exists( ( $self->{listeners} )->{$portstr} ) );
    }
    return $self->{listeners}->{$portstr};
}
1;

