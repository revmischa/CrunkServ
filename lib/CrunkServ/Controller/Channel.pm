package CrunkServ::Controller::Channel;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use CrunkServ::Util;

sub add_nick : Local {
    my ($self, $c) = @_;
    
    my $channel_id = $c->req->param('channel_id');
    my $chan = $c->model('CSDB::Channel')->find($channel_id)
        or return $c->error("Invalid channel id");
        
    my $nick_name = $c->req->param('nick');
    my $pass = $c->req->param('pass')
        or return $c->error("No password specified!");
        
    return $c->error("You are not authorized to manage " . $chan->name)
        unless $c->can_manage_channel($chan);
        
    if ($nick_name) {
        my $nick = $c->model('CSDB::Nick')->find_or_create({ nick => $nick_name });
        $nick->update({ password => $pass });
        
        if (! $chan->nicks->find($nick->id)) {
            $chan->add_to_nicks($nick);
        };
    }
    
    $c->stash->{chan} = $chan;
    $c->forward('manage');
}

sub delete_nick : Local {
    my ($self, $c) = @_;
    
    my $cn_id = $c->req->param('channel_nick_id');
    my $cn = $c->model('CSDB::ChannelNick')->find($cn_id)
        or return $c->error("Invalid channel_nick id");
        
    return $c->error("You are not authorized to manage " . $cn->channel->name)
        unless $c->can_manage_channel($cn->channel);
        
    $cn->delete;
    $c->stash->{chan} = $cn->channel;
    $c->forward('manage');
}

sub manage : Local {
    my ($self, $c) = @_;
    
    my $channel_name = CrunkServ::Util->normalize_chan_name($c->req->param('name'));
    my $channel_id = $c->req->param('id');
    my $pass = $c->req->param('pass');
    
    my $chan = $c->stash->{chan};
    
    if (! $chan && $channel_name) {
        $chan = $c->model('CSDB::Channel')->find({ name => $channel_name });
        $c->stash->{should_have_channel} = 1;
    } elsif (! $chan && $channel_id) {
        $chan = $c->model('CSDB::Channel')->find($channel_id);
        $c->stash->{should_have_channel} = 1;
    }
    
    if ($chan && $pass) {
        if ($chan->owner_password eq $pass) {
            $c->session->{can_manage_channel}{$chan->id} = 1;
        } else {
            $c->stash->{invalid_password} = 1;
        }
    }
    
    $c->stash->{template} = "channel/manage.tt2";
    $c->stash->{chan} = $chan;
}

sub register : Local {
    my ($self, $c) = @_;
    $c->stash->{template} = "channel/register.tt2";
}

sub register_do : Local {
    my ($self, $c) = @_;
    
    my $channel_name = $c->req->param('channel')
        or return $c->error("You must specify a channel name");
        
    # clean up input a little
    $channel_name = CrunkServ::Util->normalize_chan_name($channel_name);
    
    my $password = $c->req->param('pass')
        or return $c->error("You must specify a channel owner password");
    
    my $p2 = $c->req->param('p2');
    return $c->error("Passwords do not match")
        unless $password && $p2 && $password eq $p2;
        
    # does this chan exist already?
    my $channel = $c->model('CSDB::Channel')->find({ name => $channel_name });
    if ($channel) {
        return $c->error("Sorry, the channel $channel_name has already been registered. If you require assistance please join #crunkserv on efnet.");
    }

    my $email = $c->req->param('email');
    
    $channel = $c->model('CSDB::Channel')->create({
        name => $channel_name,
        owner_password => $password,
        owner_email => $email,
    });
    
    $c->session->{can_manage_channel}{$channel->id} = 1;
    
    $c->stash->{channel} = $channel;
    $c->stash->{template} = "channel/register_confirm.tt2";
}


1;
