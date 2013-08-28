package NCIPServer;

use Sys::Syslog qw(syslog);
use Modern::Perl;
use NCIP::Configuration;
use IO::Socket::INET;
use Socket qw(:DEFAULT :crlf);
use base qw(Net::Server::PreFork);

our $VERSION = '0.01';

# This sets up the configuration

my %transports = ( RAW => \&raw_transport, );

sub configure_hook {
    my ($self)        = @_;
    my $server        = $self->{'server'};
    my $config        = NCIP::Configuration->new( $server->{'config_dir'} );
    my $server_params = $config->('NCIP.server-params');
    while ( my ( $key, $val ) = each %$server_params ) {
        $server->{$key} = $val;
    }
    my $listeners = $config->('NCIP.listeners');
    foreach my $svc ( keys %$listeners ) {
        $server->{'port'} = $listeners->{$svc}->{'port'};
    }
    $self->{'local_config'} = $config;
}

# Debug, remove before release

sub post_configure_hook {
    my $self = shift;
    use Data::Dumper;
    print Dumper $self;
}

# this handles the actual requests
sub process_request {
    my $self     = shift;
    my $sockname = getsockname(STDIN);
    my ( $port, $sockaddr ) = sockaddr_in($sockname);
    $sockaddr = inet_ntoa($sockaddr);
    my $proto = $self->{server}->{client}->NS_proto();
    $self->{'service'} =
      $self->{'local_config'}->find_service( $sockaddr, $port, $proto );
    if ( !defined( $self->{service} ) ) {
        syslog( "LOG_ERR",
            "process_request: Unknown recognized server connection: %s:%s/%s",
            $sockaddr, $port, $proto );
        die "process_request: Bad server connection";
    }
    my $transport = $transports{ $self->{service}->{transport} };
    if ( !defined($transport) ) {
        syslog(
            "LOG_WARNING",
            "Unknown transport '%s', dropping",
            $self->{'service'}->{transport}
        );
        return;
    }
    else {
        &$transport($self);
    }
}

sub raw_transport {
    my $self = shift;
    my ($input);
    my $service = $self->{service};

    # place holder code, just echo at the moment
    while (1) {
        local $SIG{ALRM} = sub { die "raw_transport Timed Out!\n"; };
        $input = <STDIN>;
        if ($input) {
            print "You said $input";
        }
    }

}

1;
__END__
