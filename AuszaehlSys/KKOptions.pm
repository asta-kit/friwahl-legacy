# Option handler
# $Id: KKOptions.pm 55 2006-01-25 23:40:02Z djpig $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package KKOptions;
use Exporter ();
@ISA       = qw(Exporter);
@EXPORT    = qw(do_options);

use strict ;

sub do_options {
    my ( $src, $dst, @opt ) = @_ ;
    my %optok ;
    my $o ;
    for $o ( @opt ) {
	my $req = ! ( $o =~ s/^-// ) ;
	$optok{$o} = 1 ;
	if ( exists $src->{$o} ) {
	    $dst->{$o} = $src->{$o} ;
	} else {
	    if ( $req ) {
		die "required option '$o' missing in ".dump_caller()."\n" ;
	    }
	}
    }
    for $o ( keys %$src ) {
	if ( ! $optok{$o} ) {
	    die "unknown option '$o' in ".dump_caller()."\n" ;
	}
    }
}

sub dump_caller {
    my $called_pack = caller(1) ;
    my ( $caller_pack, $caller_file, $caller_line ) = caller(2) ;
    return "$called_pack, $caller_file:$caller_line" ;
}
