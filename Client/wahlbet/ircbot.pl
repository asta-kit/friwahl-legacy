#!/usr/bin/perl -w

use Net::IRC;
use strict;

my $irc = new Net::IRC;

my $conn = $irc->newconn(
	Server 		=> '127.0.0.1',
	Port		=> '5557', 
	Nick		=> 'WahlBot',
	Ircname		=> 'Wahlbeteiligungs-Bot - say hello to me!',
	Username	=> 'wahlbot',
	Password	=> 'EimaCh7i'
);

$conn->{channel} = '#uwahl';

sub send_wahlbet {
	my ($conn, $nick) = @_;

	system('ssh -i ~/.ssh/wahlbet_key wahlprognose@asta-wahl.asta.uni-karlsruhe.de wahl/Client/wahlbet/wahlbet.py wahl/Client/wahlbet/templates/wahlbet.irc.txt > /tmp/wahlbet.irc.txt');

	open (FILE,"</tmp/wahlbet.irc.txt");

	while (<FILE>){
		$conn->privmsg($nick,$_);
	}

	close FILE;
}

sub on_connect {
	my $conn = shift;

	$conn->join($conn->{channel});
	$conn->{connected} = 1;

}

sub on_msg {
	my ($conn, $event) = @_;

	print "request from $event->{nick}\n";

	$conn->privmsg($event->{nick}, "Hallo $event->{nick},");
	$conn->privmsg($event->{nick}, " ");

	send_wahlbet($conn,$event->{nick});
}
	
# The end of MOTD (message of the day), numbered 376 signifies we've connect
$conn->add_handler('376', \&on_connect);
$conn->add_handler('msg',\&on_msg);

# start IRC
$irc->start();
