#!/usr/bin/perl -w

# Datenbank-Login-Screen
# $Id: DBLogin.pm 151 2009-01-27 17:56:16Z mariop $
#
# (c) 2003, 2004        Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL

package DBLogin;
use Exporter ();
@ISA       = qw(Exporter);
@EXPORT    = qw(DBLogin);

use strict ;

use Tk ;
use DBI ;

sub DBLogin {
    my ( $title, $host, $dbase, $user, $command ) = @_ ;
    my $pass = "" ;

    my $login = MainWindow->new( -title => $title ) ;
    
    my $frame = $login->Frame( -borderwidth => 20 )->pack( -expand => 1 ) ;

    $frame->Label( -text => "Host:"       )->grid(-row=>0,-column=>0,-sticky=>"w") ;
    $frame->Entry( -textvariable=>\$host  )->grid(-row=>0,-column=>1,-sticky=>"w") ;

    $frame->Label( -text => "Database:"   )->grid(-row=>1,-column=>0,-sticky=>"w") ;
    $frame->Entry( -textvariable=>\$dbase )->grid(-row=>1,-column=>1,-sticky=>"w") ;

    $frame->Label( -text => "User:"       )->grid(-row=>2,-column=>0,-sticky=>"w") ;
    $frame->Entry( -textvariable=>\$user  )->grid(-row=>2,-column=>1,-sticky=>"w") ;

    $frame->Label( -text => "Password:"   )->grid(-row=>3,-column=>0,-sticky=>"w") ;
    $frame->Entry( -show=>'+', 
                   -textvariable=>\$pass  )->grid(-row=>3,-column=>1,-sticky=>"w") ;

    $frame->Frame( -height => 5           )->grid(-row=>4,-column=>0,-columnspan=>2) ;

    $frame->Button( -text=>'Login', 
		    -command=>[\&check_login, $login,
			       \$host, \$dbase, \$user, \$pass,
			       $command] )->grid(-row=>5,-column=>0, -columnspan=>2) ;
}

sub check_login {
    my ( $login, $hostref, $dbaseref, $userref, $passref, $command ) = @_ ;
    my $dbh = DBI->connect ( "DBI:mysql:database=$$dbaseref;".
			     "host=$$hostref", $$userref, $$passref ) ;
#			     "host=server.usta.de", $$userref, $$passref ) ;
    if ( defined $dbh ) {
	$login->destroy ;
	&$command($dbh, $$hostref, $$dbaseref, $$userref) ;
    } else {
	$$passref = "" ;
    }
}
