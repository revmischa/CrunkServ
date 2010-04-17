package CrunkServ::Schema::CSDB::Result::Channel;

use base DBIx::Class;
use Moose;

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("channel");
__PACKAGE__->add_columns(
	"id" => { data_type => "INT", is_nullable => 0, is_auto_increment => 1 },
	"confirmed" => { data_type => 'INT', size => 1, is_nullable => 0, default_value => 0 },
	"name" => { data_type => 'VARCHAR', size => 256, is_nullable => 0 },
	"status" => { data_type => 'INTEGER', size => 2, is_nullable => 0, default_value => 1 },
    "owner_password" => { data_type => 'VARCHAR', size => 255, is_nullable => 0 },
    "owner_email" => { data_type => 'VARCHAR', size => 512, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(channel_nicks => 'CrunkServ::Schema::CSDB::Result::ChannelNick', 'channel_id');
__PACKAGE__->many_to_many(nicks => 'channel_nicks', 'nick');

sub channel_name {
    my ($self) = @_;
    return $self->name;
}

1;
