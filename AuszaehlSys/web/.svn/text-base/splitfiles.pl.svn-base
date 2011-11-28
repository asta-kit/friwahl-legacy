#!/usr/bin/perl -w

open ( OUT, ">&STDERR" ) ;
while ( <STDIN> ) {
    if ( /^<NEWFILE (\S+) (.+)>/ ) {
	# Speichere Linktext
	my $linktext = $2;

	# entferne slash aus Dateiname
	my $out = $1;
	$out =~ s/\//_/g;
	# brutaler Hack, um ä aus Ausländer in Dateiname zu entfernen
	if($out =~ m/Ausl/) {
	    $out = "Auslaender-kandi.html";
	}
	open ( OUT, ">$out" ) ;
	print "<A href='$out?cache_dummy=".time()."'>$linktext</A><BR>\n" ;
    } elsif ( /^<NEWSECTION>/ ) {
	print "<BR>\n" ;
    } else {
	print OUT $_ ;
    }
}
