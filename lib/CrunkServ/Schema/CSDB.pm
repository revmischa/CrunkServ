package CrunkServ::Schema::CSDB;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

use CrunkServ::Util;

__PACKAGE__->load_namespaces(
	result_namespace => 'Result',
);

sub get_connection {
	my ($class) = @_;
	
	my $config = CrunkServ::Util->get_config;

	my $schema = __PACKAGE__->connect(@{$config->{'Model::CSDB'}->{connect_info}});
	return $schema;
}

1;