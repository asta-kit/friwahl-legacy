# ForeignKeys emulation for mysql
# $Id: ForeignKeys.pm 151 2009-01-27 17:56:16Z mariop $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package ForeignKeys;
use Exporter ();
@ISA       = qw(Exporter);
@EXPORT    = qw(DeleteCascade InsertChecked UpdateChecked);
@EXPORT_OK = qw(Check);

use strict ;

#
# $fkeys = [ [ master-table master-column  slave-table slave-column ],
#            [ master-table master-column  slave-table slave-column ],
#            ... 
#          ]
#
#

# TODO: Locking

sub DeleteCascade {
    my ( $dbh, $fkeys, $table, $where ) = @_ ;
    if ( defined $fkeys ) {
	my $fk ;
	foreach $fk ( @$fkeys ) {
	    my ( $master_table, $master_column, 
		 $slave_table,  $slave_column ) = @$fk ;
	    if ( $master_table eq $table ) {
		my $sth = $dbh->prepare( "SELECT $master_column ".
					 "FROM $master_table WHERE $where" ) ;
		if ( $sth->execute ) {
		    my $mc_value;
		    while ( defined ($mc_value = $sth->fetchrow_array) ) {
			DeleteCascade ( $dbh, $fkeys, $slave_table,
					$slave_column." = ".
					$dbh->quote($mc_value) ) ;
		    }
		}
		$sth->finish;
	    }
	}
    }
    my $st = "DELETE FROM $table WHERE $where" ;
    $dbh->do($st) ;
}

sub InsertChecked {
    my ( $dbh, $fkeys, $table, $href ) = @_ ;
    if ( Check ( $dbh, $fkeys, $table, $href ) ) {
	my $st = ( "INSERT INTO ".$table.
		   " (".join(",",keys %$href).")".
		   " VALUES (".join(",", 
				    map { $dbh->quote($_) } 
				    values %$href ).")" ) ;

        $st = Encode::encode("iso-8859-1", $st)
        if utf8::is_utf8($st);

	return $dbh->do($st) ;
    } else {
	return 0 ;
    }
}

sub UpdateChecked {
    my ( $dbh, $fkeys, $table, $href, $where ) = @_ ;
    if ( Check ( $dbh, $fkeys, $table, $href ) ) {
	my $st = ( "UPDATE ".$table." SET ".
		   join(", ", 
			map { $_."= ".$dbh->quote($href->{$_}) }
			keys %$href ).
		   " WHERE ".$where ) ;

        $st = Encode::encode("iso-8859-1", $st)
        if utf8::is_utf8($st);

	return $dbh->do($st) ;
    } else {
	return 0 ;
    }
}

sub Check {
    my ( $dbh, $fkeys, $table, $href ) = @_ ;
    if ( defined $fkeys ) {
	my $fk ;
	foreach $fk ( @$fkeys ) {
	    my ( $master_table, $master_column, 
		 $slave_table,  $slave_column ) = @$fk ;
	    if ( ($slave_table eq $table) &&
		 (exists $href->{$slave_table.".".$slave_column}) ) {
		my $st = "SELECT count(*) FROM $master_table ".
		    "WHERE $master_column = ".
		    $dbh->quote($href->{$slave_table.".".$slave_column}) ;
		my $n = $dbh->selectrow_array($st) ;
		if ( $n <= 0 ) {
		    return 0 ;
		}
	    }
	}
    }
    return 1 ;
}
