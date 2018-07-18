# ---------------------------------------------------------------
# Copyright © 2014 Jason J.A. Stephenson <jason@sigio.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# ---------------------------------------------------------------
package NCIP::Handler::LookupVersion;

=head1

  NCIP::Handler::LookupVersion

=head1 SYNOPSIS

    Not to be called directly, NCIP::Handler will pick the appropriate Handler
    object, given a message type

=head1 FUNCTIONS

=cut

use Modern::Perl;

use NCIP::Handler;
use NCIP::Const;

our @ISA = qw(NCIP::Handler);

sub handle {
    my $self   = shift;
    my $xmldoc = shift;
    if ($xmldoc) {
        my ( $from, $to ) = $self->get_agencies($xmldoc);

        return $self->render_output(
            'response.tt',
            {
                from_agency  => $to,
                to_agency    => $from,
                message_type => 'LookupVersionResponse',
                versions     => [NCIP::Const::SUPPORTED_VERSIONS],

            }
        );
    }
}

1;
