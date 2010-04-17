package CrunkServ::Bot;

use strict;
use warnings;

use POE qw(Component::IRC);
use LWP::Simple;
use CrunkServ::Util;
use CrunkServ::Schema::CSDB;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw/chan irc schema/);


########


my $config = CrunkServ::Util->get_config;

sub nick { $config->{botnick} }
sub ircname { $config->{name} }

our $SERVER = 'irc.efnet.nl';
#our $SERVER = 'hub.hardchats.com';

sub spawn {
    my ($class) = @_;
    
    my $irc = POE::Component::IRC->spawn( 
    	nick => $class->nick,
    	ircname => $class->ircname,
    	server => $SERVER,
        username => $class->ircname,
		UseSSL => 0,
		port => 6667,
 	) or die $!;
    
    my $self = {
        irc    =>  $irc,
        schema => CrunkServ::Schema::CSDB->get_connection,
    };
    bless $self, $class;
    
    POE::Session->create(
                         package_states => [
                                            'CrunkServ::Bot' => [ qw(
                                                _start _default irc_001 irc_join irc_msg irc_mode check_chans
                                            ) ],
                                            ],
                         heap => { irc => $irc, bot => $self, chans => {}, },
	);
    
    return $self;
}

sub _start {
    my $heap = $_[HEAP];
    
    warn "started";

    my $irc = $heap->{irc};
    my $bot = $heap->{bot};
    
    $irc->yield( register => 'all' );
    $irc->yield( connect => { } );
}

sub irc_001 {
	my ($kernel, $sender, $heap) = @_[KERNEL, SENDER, HEAP];
    my $irc = $sender->get_heap;

    print "Connected to ", $irc->server_name, "\n";

	my $bot = $heap->{bot}
	    or die "Could not get bot instance";

    $kernel->delay(check_chans => 3, $irc, $bot);
}

sub check_chans {
    my ($kernel, $sender, $heap, $irc, $bot) = @_[KERNEL, SENDER, HEAP, ARG0, ARG1];
    
    my @channels = $bot->schema->resultset('Channel')->all;
    foreach my $chan (@channels) {
        if (! exists $heap->{channels}{$chan->name}) {
            $heap->{channels}{$chan->name} = $chan;
            $irc->yield(join => $chan->name);
        }
    }
    
    $kernel->delay(check_chans => 3, $irc, $bot);
}

sub irc_join {
    my ($heap, $sender, $who, $chan) = @_[HEAP, SENDER, ARG0 .. ARG1];
    
}

sub irc_msg {
    my ($heap, $sender, $who, $rcpt, $msg) = @_[HEAP, SENDER, ARG0 .. ARG2];
    
    my $bot = $heap->{bot};
    my $irc = $sender->get_heap;
        
    $msg ||= '';
    my ($nick_name) = split('!', $who);
    my ($chan_name, $pw, $auth_nick) = $msg =~ /\s*op\s+(\S+)\s+(\S+)\s*(\S*)/i;
    $chan_name = CrunkServ::Util->normalize_chan_name($chan_name);
    
    unless ($chan_name && $pw) {
        $irc->yield(privmsg => $nick_name, "Usage is: op #channel password [nick]");
        return;
    }
    
    $auth_nick ||= $nick_name;
    
    my $chan = $heap->{channels}{$chan_name};
    unless ($chan) {
        $irc->yield(privmsg => $nick_name, "I'm not signed on to $chan_name");
        return;
    }
    
    my $nick = $chan->nicks->find({ nick => $auth_nick });
    
    unless ($nick) {
        $irc->yield(privmsg => $nick_name, "Sorry, $auth_nick is not registered for $chan_name.");
        return;
    }
    
    # check password
    if ($nick->password eq $pw) {
        print "Opping $nick_name in $chan_name with pw $pw\n";
        $irc->yield(privmsg => $nick_name, "Opping $nick_name in $chan_name");
        $irc->yield(mode => "$chan_name +o $nick_name");
        return;
    } else {
        $irc->yield(privmsg => $nick_name, "Wrong password");
        return;
    }
}

sub irc_mode {
    my ($heap, $sender, $who, $chan, $modestring, $params) = @_[HEAP, SENDER, ARG0 .. ARG1];

}




sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    my @output = ("$event: ");

    for my $arg (@$args) {
        if (ref $arg eq 'ARRAY') {
            push(@output, '[' . join(', ', @$arg ) . ']');
        }
        else {
			$arg ||= '(null)';
            push (@output, "'$arg'");
        }
    }
    print join ' ', @output, "\n";
    return 0;
}

1;