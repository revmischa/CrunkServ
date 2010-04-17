package CrunkServ::View::TT;

use strict;
use base 'Catalyst::View::TT';
use Template::Stash;

__PACKAGE__->config({
    INCLUDE_PATH => [
        CrunkServ->path_to( 'root' ),
        CrunkServ->path_to( 'root', 'src' ),
    ],
    PRE_PROCESS  => 'src/include.tt2',
    ERROR        => 'error.tt2',
    TIMER        => 0,
    INTERPOLATE  => 1,
    TEMPLATE_EXTENSION => '.tt2',
        FILTERS => {
            commafy => \&commify,
        },
});

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}

1;
