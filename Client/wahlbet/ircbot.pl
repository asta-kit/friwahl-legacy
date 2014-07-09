#!/usr/bin/perl -w

use Net::IRC;
use strict;

my $irc = new Net::IRC;

my $conn = $irc->newconn(
	Server 		=> 'fachschaft.physik.uni-karlsruhe.de',
	Port		=> '6667', 
	Nick		=> 'WahlBot',
	Ircname		=> 'Wahlbeteiligungs-Bot - say hello to me!',
	Username	=> 'wahlbot',
	Password	=> 'Eic0ien2'
);

$conn->{channel} = '#wahl';

sub send_wahlbet {
	my ($conn, $nick) = @_;

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
