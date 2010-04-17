#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use CrunkServ::Schema::CSDB;

my $schema = CrunkServ::Schema::CSDB->get_connection;
$schema->deploy({ add_drop_table => 1 });
