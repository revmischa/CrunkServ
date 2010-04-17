package CrunkServ;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

use parent qw/Catalyst/;
use Catalyst qw/
    ConfigLoader
    Static::Simple
                
    Session
    Session::State::Cookie
    Session::Store::DBIC
/;
our $VERSION = '0.01';


__PACKAGE__->config( name => 'CrunkServ' );
__PACKAGE__->setup();

sub can_manage_channel {
    my ($c, $chan) = @_;
    
    return $c->session->{can_manage_channel}{$chan->id};
}

1;
