package CrunkServ::Schema::CSDB::Result::ChannelNick;

use base DBIx::Class;
use Moose;

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("channel_nick");
__PACKAGE__->add_columns(
	"id" => { data_type => "INT", is_nullable => 0, is_auto_increment => 1 },
	"channel_id" => { data_type => 'INTEGER', is_nullable => 1 },
	"nick_id" => { data_type => 'INTEGER', is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(nick => 'CrunkServ::Schema::CSDB::Result::Nick', 'nick_id');
__PACKAGE__->belongs_to(channel => 'CrunkServ::Schema::CSDB::Result::Channel', 'channel_id');

1;
