package NCIPServer;

use Modern::Perl;
use NCIP::Configuration;

use base qw(Net::Server::PreFork);

our $VERSION = '0.01';

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
}

sub post_configure_hook {
    my $self = shift;
    use Data::Dumper;
    print Dumper $self;
}

1;
__END__
