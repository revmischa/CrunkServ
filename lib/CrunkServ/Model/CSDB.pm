package CrunkServ::Model::CSDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CrunkServ::Schema::CSDB',
);

1;
