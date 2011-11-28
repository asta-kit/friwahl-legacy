#!/usr/bin/perl

#
# $Id: testserver.pl 401 2011-01-09 18:33:05Z mariop $
#

$| = 1 ;

open ( LOG, ">testserver.log" ) ;
print LOG "Connect\n" ;

while ( <STDIN> ) {
    chomp ;
    my ($cmd, @arg) = split ;
    
    if ( $cmd eq "show-elections" ) {
	print LOG "Show Elections\n" ;
	print join ( "\n", "+ok",
		     "1 StuPa", "2 Fachschaft", 
		     "3 Frauen", "4 Auslaender" )."\n\n" ;
    } elsif ( $cmd eq "show-queue" ) {
	print LOG "Show Queue\n" ;
	print join ( "\n", "+ok",
		     ( map { join ' ', ($_), @{$queue{$_}} } keys %queue ) ).
		     "\n\n" ;
    } elsif ( $cmd eq "insert-queue-element" ) {
	$vid = shift @arg ;
	$bibnr = shift @arg ;
	$queue{$vid} = [ @arg ] ;
	print LOG "Enqueue: $vid ($bibnr) -> @arg\n" ;
	print "+ok\n" ;
    } elsif ( $cmd eq "delete-queue-element" ) {
	$vid = shift @arg ;
	delete $queue{$vid} ;
	print LOG "Delete: $vid\n" ;
	print "+ok\n" ;
    } elsif ( $cmd eq "commit-queue-element" ) {
	$vid = shift @arg ;
	delete $queue{$vid} ;
	print LOG "Commit: $vid\n" ;
	print "+ok\n" ;
    } elsif ( $cmd eq "quit" ) {
	print LOG "Quit\n" ;
	print "+ok\n" ;
	last ;
    } else {
	print LOG "SynErr: $cmd\n" ;
	print "-500 So nicht!\n" ;
    }
}

print LOG "Disconnect\n" ;
