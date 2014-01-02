package NCIP::Handler::LookupUser;

=head1

  NCIP::Handler::LookupUser

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler 
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::User;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {

        # Given our xml document, lets find our userid
        my ($user_id) =
          $xmldoc->getElementsByTagNameNS( $self->namespace(),
            'UserIdentifierValue' );

        # We may get a password, username combo instead of userid
        # Need to deal with that also

        my $user = NCIP::User->new(
            { userid => $user_id->textContent(), ils => $self->ils } );
        $user->initialise();

        # if we have blank user, we need to return that
        # and can skip looking for elementtypes

        my $root     = $xmldoc->documentElement();
        my @elements = $root->findnodes('LookupUser/UserElementType/Value');

        #set up the variables for our template
        my $vars;
        $vars->{'messagetype'} = 'LookupUserResponse';
        $vars->{'elements'}    = \@elements;
        $vars->{'user'}        = $user;
        my $output = $self->render_output( 'response.tt', $vars );
        return $output;

    }
}

1;
