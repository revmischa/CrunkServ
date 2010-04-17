#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CrunkServ::Bot;
use POE;

my $bot = eval {
    CrunkServ::Bot->spawn
};

if (! $bot || $@) {
    die "Error starting bot: $@\n";
}

$poe_kernel->run();
exit;