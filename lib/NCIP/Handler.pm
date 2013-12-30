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
use Object::Tiny qw{ type namespace ils templates };
use Module::Load;
use Template;

sub new {
    my $class    = shift;
    my $params   = shift;
    my $subclass = __PACKAGE__ . "::" . $params->{type};
    load $subclass || die "Can't load module $subclass";
    my $self = bless {
        type      => $params->{type},
        namespace => $params->{namespace},
        ils       => $params->{ils},
        templates => $params->{template_dir}
    }, $subclass;
    return $self;
}

sub render_output {
    my $self         = shift;
    my $templatename = shift;

    my $vars     = shift;
    my $template = Template->new(
        { INCLUDE_PATH => $self->templates, } );
    my $output;
    $template->process( $templatename, $vars, \$output );
    return $output;
}
1;
