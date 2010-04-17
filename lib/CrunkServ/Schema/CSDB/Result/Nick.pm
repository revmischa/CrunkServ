package CrunkServ::Schema::CSDB::Result::Nick;

use base DBIx::Class;
use Moose;

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("nick");
__PACKAGE__->add_columns(
	"id" => { data_type => "INT", is_nullable => 0, is_auto_increment => 1 },
	"nick" => { data_type => 'VARCHAR', size => 256, is_nullable => 0 },
	"type" => { data_type => 'INTEGER', size => 2, is_nullable => 0, default_value => 1 },
    "password" => { data_type => 'VARCHAR', size => 256, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(channel_nicks => 'CrunkServ::Schema::CSDB::Result::ChannelNick', 'nick_id');
__PACKAGE__->many_to_many(channels => 'channel_nicks', 'channel');

1;
