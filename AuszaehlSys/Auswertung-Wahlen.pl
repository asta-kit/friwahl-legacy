#!/usr/bin/perl -w

use Auswertung ;

use DBI ;

if ( scalar(@ARGV) != 1 ) {
    die "$0 <DB-Host>\n" ;
}

$dbh = DBI->connect ( "DBI:mysql:database=auszaehl;".
		      "host=$ARGV[0]", "auszaehl-ro", "" ) ;

Auswertung::DoWahlen($dbh) ;
