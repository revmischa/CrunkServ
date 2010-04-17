package CrunkServ::Util;

use strict;
use warnings;

use Config::JFDI;

sub get_config {
    my $config = Config::JFDI->new(name => "CrunkServ");
    my $config_hash = $config->get;
    
    return $config_hash;
}

sub normalize_chan_name {
    my ($class, $chan) = @_;
    
    return '' unless $chan;
    
    $chan =~ s/^(\s*)(.+)(\s*)$/$2/sm;
    $chan = '#' . $chan unless $chan =~ /^\#/;
    
    return $chan;
}

1;