#!/usr/bin/perl -w
#
# (c) 2007-2008 Sebastian Maisch <s_maisch@usta.de>
# (c) 2010-2011 Mario Prausa <mariop@usta.de>
#
# $Id: friwahl-client.pl 447 2011-01-15 14:46:27Z mariop $
#

$semester="Wintersemester 2010/11";	# notwendig für die Überprüfung von Studienbescheinigungen

$timeout = 30 ;

use IPC::Open3 ;
use POSIX;
use WWW::Curl::Easy;


$| = 1 ;

#################### Setup signal handling

$backtitle = "FriWahl";
$server_died = 0 ;
$kill_dialog = 0 ;
$SIG{CHLD} = sigchild_handler ;
$SIG{PIPE} = sub { } ;
$SIG{ALRM} = sub { die "alarm\n" } ;

#################### Setup connection

if ( scalar(@ARGV) == 1 ) {
    dialog_message ( "FriWahl TESTMODUS", 
		     "Start im Testmodus\nmit externem Programm\n" ) ;
    $serverpid = open3 ( \*SERVER_OUT, \*SERVER_IN, \*SERVER_ERR, $ARGV[0] ) ;

} elsif ( scalar(@ARGV) == 2 ) {
    dialog_message ( "FriWahl TESTMODUS", 
		  "Start im Testmodus\nmit TCP-Verbindung\n" ) ;
    $serverpid = open3 ( \*SERVER_OUT, \*SERVER_IN, \*SERVER_ERR,
			 'socket', '-q', $ARGV[0], $ARGV[1] ) ;
    realsleep(1) ;
    
} elsif ( scalar(@ARGV) == 3 ) {
    $backtitle = "FriWahl - $ARGV[1]";

    dialog_info ( "FriWahl", 
		  "Willkommen an der\nFriWahl-Station!\n", "--beep" ) ;
    realsleep(3) ;
    dialog_info ( "Information", 
		  "Verbindung zum Server wird hergestellt...\n" ) ;
    $serverpid = open3 ( \*SERVER_OUT, \*SERVER_IN, \*SERVER_ERR,
			 'ssh', 
			 '-o', 'BatchMode yes', 
			 '-o', 'HostKeyAlias asta-wahl.asta.uni-karlsruhe.de',
			 '-i', $ARGV[2],
			 '-l', $ARGV[1],
			 $ARGV[0], 
			 'false' ) ;
    realsleep(2) ;
    
} else {
    die "usage: friwahl-client.pl <server> <user> <keyfile>\n".
	"   or: friwahl-client.pl <server> <port>\n".
	"   or: friwahl-client.pl <program>\n" ;
}    

get_elections() ;

for (;;) {
    main_menu() ;
}


#################### Read and check elections

sub get_elections {
    my ( $ok, @tmp ) = server_list ( "show-elections" ) ;
    if ( ! $ok ) {
	exit -1 ;
    }

    if ( scalar(@tmp) == 0 ) {
	dialog_message ( "Problem", 
			 "Keine Wahlen vom Server erhalten" ) ;
	exit -1 ;
    }

    @elections = () ;
    %elections = () ;
    foreach ( @tmp ) {
	my ( $tag, $name ) = split / /, $_, 2 ;
	if ( ! defined $name ) {
	    dialog_message ( "Problem", 
			     "Formatfehler bei Servermeldung" ) ;
	    exit -1 ;
	}
	push @elections, [ $tag, $name ] ;
	$elections{$tag} = $name ;
    }

    dialog_message ( "Information", 
		     "Folgende Wahlen wurden vom Server erhalten:\n\n".
		     join ( ", ", map { $_->[1] } @elections ) ) ;
}

#################### Main Menu

sub main_menu {

    dialog_info ( "Information", 
		  "Vorgemerkte Wähler werden abgefragt...\n" ) ;
    my (undef, @tmp) = server_list ( "show-queue" ) ;
    %queue = map { ($vid, @eid) = split / /; ($vid, [@eid]); } @tmp ;
    
    my ($rv, $m) = sigchild_wrapper ( sub {
	dialog_menu_nocancel ( "FriWahl-Menü",
		      "Bitte nächsten Schritt auswählen:",
		      [ 
			[ "N", "Neuen Wähler eingeben" ],
			( map {[$_, 
				"Vorgemerkten Wähler aufrufen"]} 
			  sort keys %queue ),
			[ "E", "Wahlsitzung beenden" ] ] ) 
	} ) ;
	
    if ( ($rv != 0) || ($m eq "E") ) {
	my ( $rv ) = dialog_yesno ( "Beenden", 
				    "Wahlsitzung wirklich schließen?",
				    "--defaultno" ) ;
	if ( $rv == 0 ) {
	    server_send ( "quit" ) ;
	    exit 0 ;
	}
    } elsif ( $m eq "N" ) {
	new_voter() ;
    } else {
	handle_voter($m) ;
    }
}


#################### add a new voter to the queue
sub new_voter {
    my ( $vid ) = ask_voter() ;
    if ( ! defined $vid ) {
	return ;
    }
    my ( @el ) = ask_elections ( $vid ) ;
    if ( scalar(@el) == 0 ) {
	return ;
    }

    my $ok=0;

    do {
	    my $bibnr = ask_bibNum($vid);
    
    	    if ( defined $bibnr) {
		 if ($bibnr != -1) {
    	            $ok = server_send_info ( "Vormerkung wird zum Server übermittelt...",
		       "Der Wähler wurde vorgemerkt\n\nBitte den Ausweis des Wählers behalten, bis er gewählt hat!",
		       "insert-queue-element", $vid, $bibnr, @el ) ;
	         } else {
		    $ok = 1;
		 }
	    }
    } while(!$ok);
}


#################### ask for voter
sub ask_voter {

    ################ Read VoterID
    my ($rv, $vid) = sigchild_wrapper ( sub {
	dialog_input ( "Waehler-ID", 
		       "Bitte die Waehler-ID eingeben\n",
		       "--max-input", 30 ) } ) ;
    if ( $rv != 0 ) {
	dialog_message ( "Abbruch", "Waehler-Eingabe abgebrochen\n" ) ;
	return ;
    }
    
    if ( ! ( defined $vid && $vid =~ /^[0-9a-zA-Z]+$/ ) ) {
	dialog_message ( "Fehleingabe", 
			 "Waehler-ID darf nur aus Zahlen ".
			 "und Buchstaben bestehen", "--beep" ) ;
	return ;
    }
    my ( $matnr  ) = ( $vid =~ /^(\d+)/ );
    if (!valid_matnr( $matnr )) {
	dialog_message( "Fehleingabe",
			"Pruefsumme der Matrikelnummer ist falsch. ".
			"Wahrscheinlich liegt ein Fehler bei der Eingabe ".
			"vor.", "--beep" ) ;
	return ;
    }

    ################ Retype
    my ($rv2, $vid2) = sigchild_wrapper ( sub {
	dialog_input ( "Waehler-ID", 
		       "WIEDERHOLUNG: Bitte die Waehler-ID ".
		       "nochmal eingeben\n",
		       "--max-input", 30 ) } ) ;
    if ( $rv2 != 0 ) {
	dialog_message ( "Abbruch", "Waehler-Eingabe abgebrochen\n" ) ;
	return ;
    }
    
    if ( ! ( defined $vid2 && $vid eq $vid2 ) ) {
	dialog_message ( "Fehleingabe", 
			 "Die Waehler-IDs stimmen nicht ueberein.\n".
			 "Waehler-Eingabe abgebrochen", "--beep" ) ;
	return ;
    }
    
    return $vid ;
}


#################### Bibiliotheksnummer holen 
sub ask_bibNum {
    my ( $vid ) = @_ ;

    my ($rv0, $m) = dialog_menu ( "Wahlberechtigung",
	 			  "Wähler $vid",
				  [ [ "1", "Bibliotheksnummer überprüfen" ],
				    [ "2", "Bescheinigung überprüfen" ],
				    [ "3", "Wahlberechtigung anderweitig überprüft" ] ] ) ;
    if ( $rv0 != 0) {
        dialog_message ( "Abbruch", "Überprüfung abgebrochen\n" ) ;
        return -1;
    }

    if ( $m eq "1" ) {
      my ($rv, $bibnr) = sigchild_wrapper ( sub {
        dialog_input ( "Bibliotheksnummer", 
          "Bitte die Bibliotheksnummer eingeben\n",
          "--max-input", 12 ) } ) ;
      if ( $rv != 0 ) {
        dialog_message ( "Abbruch", "Waehler-Eingabe abgebrochen\n" ) ;
        return ;
      }
      
      if ( ! ( defined $bibnr && $bibnr =~ /^[0-9]+$/ && length($bibnr) == 12 ) ) {
        dialog_message ( "Fehleingabe", "Bibliotheksnummer besteht aus 12 Ziffern ", "--beep" ) ;
        return ;
      }
      
      return $bibnr;
    } elsif ( $m eq "2" ) {
	if (verify_cert() != 0) {
		return ;
	}

	return 0;
    } elsif ( $m eq "3" ) {
      # Scheinbar wurde die Wahlberechtigung schon geprueft
      return 0;
    }

    # Fallthrough
    return ;
}

sub verify_cert {
	my ($rv,$verid) = sigchild_wrapper(sub{dialog_input ("Verifikation von Bescheinigungen","Verifikationsschlüssel","--max-input",12)});
	if ($rv != 0) {
		dialog_message ("Abbruch", "Eingabe abgebrochen\n");
		return -1;
	}

	if (length($verid) != 12) {
		dialog_message ("Fehler", "Verifikationsschlüssel muss aus 12 Zeichen bestehen\n");
		return -1;
	}

	my $verid1 = substr($verid,0,4);
	my $verid2 = substr($verid,4,4);
	my $verid3 = substr($verid,8,4);

	my $curl = WWW::Curl::Easy->new;
	my $body;

	$curl->setopt(CURLOPT_HEADER,1);
	$curl->setopt(CURLOPT_URL,"https://zvwgate.zvw.uni-karlsruhe.de/qispos/servlet/de.his.servlet.RequestDispatcherServlet?state=verify");
	$curl->setopt(CURLOPT_POST,1);
	$curl->setopt(CURLOPT_POSTFIELDS,"Verifyid1=".$verid1."&Verifyid2=".$verid2."&Verifyid3=".$verid3);

	$body='';
	open(my $fileb, ">", \$body);
	$curl->setopt(CURLOPT_WRITEDATA,$fileb);

	$rv = $curl->perform;

	if ($rv != 0) {
		dialog_message("Fehler",$rv." ".$curl->strerror($rv)."\n");
		return -1;
	}

	my $httpcode = $curl->getinfo(CURLINFO_HTTP_CODE);

	if ($httpcode != 200) {
		dialog_message("Fehler","HTTP-Fehler: ".$httpcode."\n");
		return -1;
	}

	my $pos = index($body,"Die Verifikationsnummer ist falsch");
	if ($pos != -1) {
		dialog_message("Fehler","Verifikationsschlüssel ist UNGÜLTIG!");
		return -1;
	}

	$pos = index($body,"KVV-Bescheinigung/KVV-Netzfahrkarte");

	if ($pos != -1) {
		my $name = "";
		$pos = index($body,"für&nbsp;",$pos+35);
		if ($pos == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}
		my $pos2 = index($body," vor.",$pos+10);
		if ($pos2 == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}	
		
		$name = substr($body,$pos+10,$pos2-$pos-10);

		$pos = index($body,"FriCard Nr:");
		if ($pos == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}	

		$pos2 = index($body,", die Karte",$pos);
		if ($pos2 == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}	
	
		my $fricard = substr($body,$pos+12,$pos2-$pos-12);

		$pos = index($body,"ist gültig für das ".$semester);
		my $valid = $pos!=-1;

		dialog_message("KVV-Bescheinigung","Name: ".$name."\nFriCard Nr: ".$fricard."\n".($valid?"--- gültig ---":"--- UNGÜLTIG ---"));

		if ($valid) {
			dialog_message("Anmerkung","KVV-Bescheinigungen sind nur in Verbindung mit einem Studentenausweis gültig, da die Richtigkeit der Matrikelnummer sichergestellt werden muss!");
		}

		return -1;
	}

	$pos = index($body,"STUDIENBESCHEINIGUNG");

	if ($pos != -1) {
		my $name = "";
		$pos = index($body,"für&nbsp;",$pos+20);
		if ($pos == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}
		my $pos2 = index($body," vor.",$pos+10);
		if ($pos2 == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}	
		
		$name = substr($body,$pos+10,$pos2-$pos-10);

		$pos = index($body,"ist gültig für das ".$semester);
		my $valid = $pos!=-1;

		dialog_message("Studienbescheinigung","Name: ".$name."\n".($valid?"--- gültig ---":"--- UNGÜLTIG ---"));

		if ($valid) {
			($rv) = dialog_yesno("","Identität mit einem Lichtbildausweis geprüft?","--defaultno");
			return $rv?-1:0;
			
		}

		return -1;
	}

	$pos = index($body,"Certificate of Registration");

	if ($pos != -1) {
		my $name = "";
		$pos = index($body,"für&nbsp;",$pos+20);
		if ($pos == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}
		my $pos2 = index($body," vor.",$pos+10);
		if ($pos2 == -1) {
			dialog_message("Fehler","interner Fehler");
			return -1;
		}	
		
		$name = substr($body,$pos+10,$pos2-$pos-10);

		$pos = index($body,"ist gültig für das ".$semester);
		my $valid = $pos!=-1;

		dialog_message("Certificate of Registration","Name: ".$name."\n".($valid?"--- gültig ---":"--- UNGÜLTIG ---"));

		if ($valid) {
			($rv) = dialog_yesno("","Identität mit einem Lichtbildausweis geprüft?","--defaultno");
			return $rv?-1:0;
			
		}

		return -1;
	}

	dialog_message("Fehler","Bescheinigung nicht erkannt\n");

	return -1;
}

#################### check validity of the id
# for details about the algorithm see checkMatrikel() in
# FriCardWahl.sql from the server code
sub valid_matnr {
    my ( $matnr ) = @_ ;

    if ( $matnr < 100_000 ) {
	return 1 ;
    }

    my $pz = $matnr % 10 ;
    
    my $mk = ( $matnr - $pz ) / 10 ;

    $t = ( $mk % 10 ) ;
    $mk = $mk / 10 ;
    $t = $t + ( $mk % 10 ) * 2 ;
    $mk = $mk / 10 ;
    $t = $t + ( $mk % 10 ) * 3 ;
    $mk = $mk / 10 ;
    $t = $t + ( $mk % 10 ) * 4 ;
    $mk = $mk / 10 ;
    $t = $t + ( $mk % 10) ;
    $mk = $mk / 10 ;
    $t = $t + ( $mk % 10 ) * 2 ;
    
    if ( ( $t % 10 ) == $pz ) {
	return 1 ;
    }

    return 0 ;
}
    
#################### choose actions on a queued voter

sub handle_voter {
    my ( $vid ) = @_ ;
    my ( $etxt ) ;
    $etxt = join ( ', ', map { $elections{$_} } @{$queue{$vid}} ) ;
 
    my ($rv, $m) = dialog_menu_nocancel ( "Fertigstellen",
				 "Wähler $vid\nWahlen: $etxt",
				 [ [ "S", "Senden an Server" ],
				   [ "V", "Verwerfen" ],
				   [ "Z", "Zurück" ] ] ) ;
    if ( $rv != 0 ) {
	dialog_message ( "Abbruch", "Auswahl abgebrochen" ) ;
    } elsif ( $m eq "S" ) {
	server_send_info ( "Wahl wird zum Server übermittelt...",
			   "Wahl wurde erfolgreich eingetragen\n\nDer Wähler darf die Stimmzettel einwerfen und im Urnenbuch unterschreiben.",
			   "commit-queue-element", $vid ) ;
    } elsif ( $m eq "V" ) {
	server_send_info ( "Abbruch wird zum Server übermittelt...",
			   "Wähler wurde erfolgreich verworfen.",
			   "delete-queue-element", $vid ) ;
    }
}

################ Ask for choices

sub ask_elections {
    my ( $vid ) = @_ ;
    for(;;) {
	my ($rv, @el) = sigchild_wrapper ( sub {
	    dialog_checklist ( "Wahlen",
			       "Bitte die Teilname an den Wahlen ".
			       "eingeben.\n".
			       "Waehler: ".$vid."\n",
			       \@elections ) } ) ;
	if ( $rv != 0 ) {
	    dialog_message ( "Abbruch", "Eingabe abgebrochen" ) ;
	    return () ;
	}
	if ( scalar(@el) == 0 ) {
	    dialog_message ( "Fehleingabe", "Keine Wahlen ausgewaehlt" ) ;
	    next ;
	}
	return @el ;
    }
}

## server_send wrapper with info boxes
sub server_send_info {
    my ( $info, $success, @send ) = @_ ;
    dialog_info ( "Information", $info ) ;
    my ( $ok ) = server_send ( @send ) ;
    if ( $ok ) {
	dialog_message ( "Erfolg", $success ) ;
    }
    return $ok ;
}


#################### server handling

## send command line to server and check return code
sub server_send {
    my ( $cmd, @args ) = @_ ;
    alarm $timeout ;
    my ( $ok ) = eval { print SERVER_OUT join( ' ', $cmd, @args )."\n" } ;
    alarm 0 ;
    if ( ! $ok ) {
	do_server_error() ;
    }
    my ($recv) = server_getline() ;
    if ( $recv =~ /^\+/ ) {
	return 1 ;
    } elsif ( $recv =~ /^-(\S+) (.*)/ ) {
	dialog_message ( "Problem", 
			 "Fehlermeldung vom Server!\n\n".
			 "$2 ($1)", "--beep" ) ;
	return 0 ;
    } else {
	dialog_message ( "Problem", 
			 "Ungültige Antwort vom Server!\n\n".
			 $recv, "--beep" ) ;
	exit -1 ;
    }
}

## send command and retrieve result list
sub server_list {
    if ( ! server_send(@_) ) {
	return ( 0 ) ;
    }
    my ( $ln, @list ) ;
    while ( ($ln = server_getline()) ne "" ) {
	push @list, $ln ;
    }
    return ( 1, @list ) ;
}

## read one line from server, check for timeout and disconnect
sub server_getline {
    alarm $timeout ;
    my ( $recv ) ;
    $recv = eval { return <SERVER_IN> } ;
    alarm 0 ;
    if ( ! defined $recv ) {
	do_server_error() ;
    }
    $recv =~ s/[\r\n]//g ;
    return $recv ;
}


## This wrapper makes the dialog interruptible
## (some dialogs should not be interrupted)

sub sigchild_wrapper {
    if ( $server_died ) {
	do_server_error() ;
    }
    $kill_dialog = 1 ;
    if ( wantarray() ) {
	@rv = &{$_[0]} ;
    } else {
	$rv = &{$_[0]} ;
    }
    $kill_dialog = 0 ;
    if ( $server_died ) {
	do_server_error() ;
    }
    if ( wantarray() ) {
	return @rv ;
    } else {
	return $rv ;
    }
}

## if server died: retrieve remaining stuff and display

sub do_server_error {
    my ( $server_err ) = "" ;
    alarm 10 ;
    eval {
	while ( <SERVER_IN> ) {
	    my $i;
	    for($i=0; $i<length($_) && !isgraph(substr($_,$i,1)); $i++) {}
	    $server_err .= substr($_,$i);
	}
    } ;
    alarm 10 ;
    eval {
	while ( <SERVER_ERR> ) {
	    my $i;
	    for($i=0; $i<length($_) && !isgraph(substr($_,$i,1)); $i++) {}
	    $server_err .= substr($_,$i);
	}
    } ;
    alarm 0 ;

   
    if ( $server_err =~ /^-(\S+) (.*)/ ) {
	if ( $1 == 1023) {
		$ENV{'DIALOGRC'} = '/etc/dialogrc.red';

	    	dialog_message ( "Problem", 
		    	     "Verbindung zum Server abgebrochen\n\n".
			     "$2", "--beep" ) ;

    	        delete $ENV{'DIALOGRC'};
	} else {
	    	dialog_message ( "Problem", 
		    	     "Verbindung zum Server abgebrochen\n\n".
			     "$2 ($1)", "--beep" ) ;
	}
    } else {
    	dialog_message ( "Problem", 
	    	     "Verbindung zum Server abgebrochen\n\n".
		     $server_err, "--beep" ) ;
    }
    exit -1 ;
}

## upon exit kill server connection process

sub END {
    my ( $ex ) = $? ;
    if ( (defined $serverpid) && (! $server_died) ) {
	kill 3, $serverpid ;
	waitpid ( $serverpid, 0 ) ;
    }
    close SERVER_OUT ;
    close SERVER_IN ;
    close SERVER_ERR ;
    $? = $ex ;
}


## if server connection dies, kill current dialog
## (if made interuptible)

sub sigchild_handler { 
    my $child = waitpid(-1,1);
    if (defined $dialogpid && $child == $dialogpid) {
	    if ($?>=0) {
		    $dialog_status = $?>>8;
	    }
    }
    elsif (defined $serverpid && $child == $serverpid) {
	    $server_died = 1 ;
	    if ( $kill_dialog && defined $dialogpid ) {
     	        kill 2, $dialogpid ;
		waitpid ( $dialogpid, 0 ) ;
		$dialog_status = -1;
	    }
    }
    else {
        $last_died_pid = $child;
        $last_died_status = $?>>8;
    }
}


#################### misc

sub realsleep {
    my ( $sec ) = @_ ;
    while ( $sec > 0 ) {
	$sec -= sleep($sec) ;
    }
}

#################### dialog convenience

sub dialog_info {
    my ( $title, $text, @opt ) = @_ ;
    call_dialog ( '--backtitle', $backtitle,
		  '--cr-wrap',
		  '--title',     $title,
		  @opt,
		  '--infobox',   $text, -1, -1 ) ;
}

sub dialog_message {
    my ( $title, $text, @opt ) = @_ ;
    call_dialog ( '--backtitle', $backtitle,
		  '--backfoot',  'RETURN zum Bestaetigen',
		  '--cr-wrap',
		  '--title',     $title,
		  @opt,
		  '--msgbox',    $text, -1, -1 ) ;
}

sub dialog_yesno {
    my ( $title, $text, @opt ) = @_ ;
    return call_dialog ( '--backtitle',    $backtitle,
			 '--backfoot',     
			 'Pfeiltasten zum Wechseln, RETURN zum Bestaetigen',
			 '--cr-wrap',
			 '--title',        $title,
			 '--yes-label',    'Ja',
			 '--no-label',     'Nein',
			 @opt,
			 '--yesno',        $text, -1, -1 ) ;
}


sub dialog_input {
    my ( $title, $text, @opt ) = @_ ;
    return call_dialog ( '--backtitle',    $backtitle,
			 '--backfoot',     
			 'Text eingeben, RETURN zum Bestaetigen, '.
			 'ESC zum Abbrechen',
			 '--cr-wrap',
			 '--title',        $title,
			 '--cancel-label', 'Abbruch', 
			 @opt,
			 '--inputbox',     $text, -1, -1 ) ;
}

sub dialog_checklist {
    my ( $title, $text, $choices, $active ) = @_ ;

    $active = [] unless defined $active ;
    my ( %active ) = map { ($_,1) } @$active ;

    my ( $height ) = scalar(@$choices) ;
    if ( $height > 10 ) { $height = 10 ; }

    return call_dialog ( '--backtitle',    $backtitle,
			 '--backfoot',     
			 '[*]=ausgew., '.
			 'Zahlen/Buchst. zum Auswaehlen, '.
			 'RETURN zum Bestaetigen, '.
			 'ESC zum Abbrechen',
			 '--cr-wrap',
			 '--separate-output',
			 '--auto-toggle',
			 '--title',        $title,
			 '--cancel-label', 'Abbruch', 
			 '--checklist',    $text, $height+8, 60, $height,
			 map { ( $_->[0], $_->[1], 
				 $active{$_->[0]} ? "on" : "off" ) } 
			       @$choices ) ;
}

sub dialog_menu {
    my ( $title, $text, $choices ) = @_ ;

    my ( $height ) = scalar(@$choices) ;
    my ( $txtheight ) = textheight($text,56);

    if ( $height > 10 ) { $height = 10 ; }

    return call_dialog ( '--backtitle',    $backtitle,
			 '--backfoot',
			 'Zahlen/Buchst./Pfeiltasten zum Auswaehlen, '.
			 'RETURN zum Bestaetigen, '.
			 'ESC zum Abbrechen',
			 '--cr-wrap',
			 '--title',        $title,
			 '--cancel-label', 'Abbruch', 
			 '--menu',    $text, $height+$txtheight+7, 60, $height,
			 map { ( $_->[0], $_->[1] ) } @$choices ) ;
}

sub dialog_menu_nocancel {
    my ( $title, $text, $choices ) = @_ ;

    my ( $height ) = scalar(@$choices) ;
    my ( $txtheight ) = textheight($text,56);

    if ( $height > 10 ) { $height = 10 ; }

    return call_dialog ( '--backtitle',    $backtitle,
			 '--backfoot',
			 'Zahlen/Buchst./Pfeiltasten zum Auswaehlen, '.
			 'RETURN zum Bestaetigen, '.
			 'ESC zum Abbrechen',
			 '--cr-wrap',
			 '--title',        $title,
			 '--no-cancel', 
			 '--menu',    $text, $height+$txtheight+7, 60, $height,
			 map { ( $_->[0], $_->[1] ) } @$choices ) ;
}

#################### dialog core

sub call_dialog {
    my ( @args ) = @_ ;

    # shamelessly ripped from dialog.pl

    pipe(DLG_PARENT_READER, DLG_CHILD_WRITER);
    $dialogpid = fork;

    # fail
    if ($dialogpid < 0) {
	die "fork() failed\n" ;
    }

    # child
    if ($dialogpid == 0) {
        close(DLG_PARENT_READER);
        open(STDERR, ">&DLG_CHILD_WRITER");
        exec('dialog',@args);
        die("exec() failed\n");
    }

    #parent
    close(DLG_CHILD_WRITER);

    my ( @result ) = ();
    while (<DLG_PARENT_READER>) {
	chomp;
	push @result, $_;
    }

    close(DLG_PARENT_READER);
    
    # This is to prevent a race condition (see also sigchild_handler)
    # $dialogpid is not defined early enough for the sigchild_handler,
    # so it just stores the information in a global variable for us to
    # retrieve later on.
    if (defined $last_died_pid && $last_died_pid == $dialogpid) {
    	$last_died_pid = undef;
        $dialog_status = $last_died_status;
    }
    
    until (defined $dialog_status) {
	    sleep 1;
    };

    my $retcode = $dialog_status;
    $dialog_status = undef;

    $dialogpid = undef ;
    return ( $retcode, @result ) ;
}

##################### textheight

sub textheight {
	my ($text, $width) = @_;

	my $count=0;
	my $space=0;
	my $height=1;

	for ($i=0; $i<length($text); $i++) {
		$c = substr($text,$i,1);
		$count++;
		if ($c eq " ") {
			$space=$i;
		} elsif ($c eq "\n") {
			$space=$i;
			$count=0;
			$height++;
		}
	
		if ($count > $width) {
			$count = $i-$space;
			if ($count > $width) {
				$count=0;
			}
			$height++;
		}
	}	

	return $height;
}

######################################################################
