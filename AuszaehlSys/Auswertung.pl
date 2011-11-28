#!/usr/bin/perl -w

use Auswertung ;

use DBI ;

if ( scalar(@ARGV) != 2 ) {
    die "$0 <DB-Host> <DB-Auth>\n" ;
}

$dbh = DBI->connect ( "DBI:mysql:database=auszaehl;".
		      "host=$ARGV[0]", "auszaehl", $ARGV[1] ) ;

Auswertung::DoWahlen($dbh) ;
Auswertung::DoListen($dbh) ;
Auswertung::DoKandidaten($dbh) ;
