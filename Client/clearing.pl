#!/usr/bin/perl -w
#
# Datenbank-Frontend fuer das elektronische Waehlerverzeichnis
#
# (c) 2002-2004 Christoph Moench-Tegeder <moench-tegeder@rz.uni-karlsruhe.de>
#               Peter Schlaile <Peter.Schlaile@stud.uni-karlsruhe.de>
#               Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
# (c) 2007-2008 Sebastian Maisch <s_maisch@usta.de>
# (c) 2010-2011 Mario Prausa <mariop@usta.de>
#
# Published under GPL
#
# Eingaben werden auf stdin entgegengenommen, alle relevanten Ausgaben
# kommen auf stdout.
# Dieses Programm ist dazu gedacht, via ssh auf dem Verzeichnis-Server
# ausgefuehrt zu werden, die ssh-Verbindung sorgt dabei fuer
# Authentifizierung, Integritaetssicherung und vertrauliche Kommunikation.
# Der Einsatz von Public-Key-Authentifizierung fuer die ssh wird
# stark empfohlen, da sich dabei die Moeglichkeiten zum Missbrauch
# der User-IDs auf dem Server (per "command=..."-Option am Public Key)
# ganz erheblich einschraenken, wenn nicht gar beseitigen lassen.
# 
# Vorausgesetzte Perl-Module:
#   - Pg  (zu PostgreSQL, libpgperl)
#

use strict;
use Pg;

$| = 1 ;
$SIG{'HUP'} = 'IGNORE' ;
$SIG{'USR1'} = \&forced_logout_handler;

my ($dbname, $dbuser)=("wahl", $ENV{'USER'});
my ($dbconn, $ret, $res, $sql, @row);
my ($request, $matr, $buchst, $sshclient, $t);
my ($cmd, $par, $inp, @inarray);

# Wenn die Wahl vom Client kommt (per SSH) ist SSH_CLIENT im Environment
# gesetzt. Fuer das Logging wird die IP erstmal festgehalten.
# Ist SSH_CLIENT nicht verfuegbar, liegt vermutlich der Debug-Fall vor
# und wir schreiben "127.0.0.1"
$sshclient='127.0.0.1';
$request="";
if(defined $ENV{'SSH_CLIENT'}) {
	$t=$ENV{'SSH_CLIENT'};
	# ggf. IPv6-Prefix loswerden
	if($t=~/^::ffff:(.+)$/) {
		$t=$1;
		}
	($sshclient, undef, undef)=split(' ', $t);
	}

# Connect zur Datenbank
$dbconn=Pg::connectdb("dbname=$dbname user=$dbuser");
$ret=$dbconn->status;
if($ret eq PGRES_CONNECTION_BAD) {
	# Wenn das passiert, ist was kaputt.
	print("-65534 ", $dbconn->errorMessage, "\n\r");
	exit(1);
	}

# Wenn die Urne schon verbunden ist, alte Urne informieren

$sql="select sessionmgmt(1, \'$sshclient\', $$)";
$res=$dbconn->exec($sql);
if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
	print("-65534 ", $dbconn->errorMessage, "\n\r");
	$dbconn->reset;
	exit(1);
	}
@row=$res->fetchrow();
if($row[0] eq -1) {
	sleep(5);
	print("-0 Urne darf nicht benutzt werden\n\r");
	$dbconn->reset;
	exit(1);
}
if (not ($row[0] eq 0)) {
	# Informiere alte Session
	kill 'SIGUSR1',$row[0];
	sleep(10);

	$sql="select sessionmgmt(1, \'$sshclient\', $$)";
	$res=$dbconn->exec($sql);
	if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
		print("-65534 ", $dbconn->errorMessage, "\n\r");
		$dbconn->reset;
		exit(1);
		}
	@row=$res->fetchrow();
	if($row[0] eq -1) {
		sleep(5);
		print("-0 Urne darf nicht benutzt werden\n\r");
		$dbconn->reset;
		exit(1);
	}
	if (not ($row[0] eq 0)) {
		sleep(5);
		print("-0 Urne funktioniert nicht. Bitte den Wahlausschuss informieren\n\r");
		$dbconn->reset;
		exit(1);
	}
}

# Id und gewuenschte Stimmmen von stdin lesen
while(defined sysread(STDIN, $inp, 1024)) {
	last if $inp eq '';
	chomp($inp);

	# Eingabe ist <Request> [<Parameter>]
	(@inarray)=split(' ', $inp);
	parerror() if(not defined $inarray[0]);

	$cmd=shift(@inarray);

	# Befehlsschleife
	if(lc($cmd) eq 'show-elections') {
		parerror() if(defined $inarray[0]);
		show_elections();
		}
	elsif(lc($cmd) eq 'show-queue') {
		parerror() if(defined $inarray[0]);
		show_queue();
		}
  	elsif(lc($cmd) eq 'insert-queue-element') {
		parerror() if(not defined $inarray[0] or not defined $inarray[1]);
		insert_queue_element(@inarray);
    	}
	elsif(lc($cmd) eq 'commit-queue-element') {
		parerror() if(not defined $inarray[0] or defined $inarray[1]);
		commit_queue_element(@inarray);
		}
	elsif(lc($cmd) eq 'delete-queue-element') {
		parerror() if(not defined $inarray[0] or defined $inarray[1]);
		delete_queue_element($inarray[0]);
		}
	elsif(lc($cmd) eq 'quit') {
		logout();
		print("+OK\n\r");
		exit(0);
		}
	else {
		parerror();
		}
	}

# Auf stdin kommt nichts mehr (EOF), also wurde die Verbindung abgebaut.
# Datenbank mitteilen, dass die Session jetzt beendet ist
logout();


# Fehlerbehandlung bei ungueltigen Requests
sub parerror {
	my $sql;

	sleep(5);
	print("-65533 Protokollfehler\n\r");
	$sql="select sessionmgmt(2, \'$sshclient\')";
	$dbconn->exec($sql);
	$dbconn->reset;
	exit(1);
	}


# Beenden der Session und Datenbankverbindung schliessen
sub logout {
	my $sql;

	$sql="select sessionmgmt(2, \'$sshclient\',0)";
	$dbconn->exec($sql);
	$dbconn->reset;

	return 0;
	}


# Waehler-ID in Matrikelnummer und Zahlen aufteilen
sub splitid {
	my $voter=$_[0];
	my ($matr, $buchst);

	return undef unless($voter=~/^(\d+)([A-Za-z]{2})$/);
	($matr, $buchst)=($1, uc($2));

	return ($matr, $buchst);
	}



# Die derzeit moeglichen Wahlen aus der Datenbank holen und dem Client
# anzeigen.
sub show_elections {
	my ($sql, $res, @row);
	$sql="select * from t_wahlen order by wahl_nr asc";
	$res=$dbconn->exec($sql);
	if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
		print("-65534 ", $dbconn->errorMessage, "\n\r");
		logout();
		exit(1);
		}

	print("+OK\n\r");
	while(@row=$res->fetchrow()) {
		print(join(' ', @row), "\n\r");
		}

	# Leere Zeile zeigt Ende der Wahlliste an
	print("\n\r");

	return 0;
	}

# Queue anzeigen
sub show_queue {
	my ($sql, $res, $row, $t);
	my %out;

	$sql="select * from v_queue order by vqueue_matr";
	$res=$dbconn->exec($sql);
	if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
		print("-65534", $dbconn->errorMessage, "\n\r");
		}
	else {
		while(@row=$res->fetchrow()) {
			$t=$row[0] . $row[1];
			if(exists $out{$t}) {
				$out{$t}.=" " . $row[2];
				}
			else {
				$out{$t}=$row[2];
				}
			}

		print("+OK\n\r");
		foreach $t (sort(keys(%out))) {
			print($t . " " . $out{$t} . "\n\r");
			}
		print("\n\r");
		}

	return 0;
	}

sub insert_queue_element {
  my $voter=shift(@_);
  my $bibnr=shift(@_);

  my ($sql, $res, $row, $matr, $buchst);
  
  ($matr, $buchst)=splitid($voter);
  #parerror() if(not defined $matr);
        unless ($matr) {
    print("-99 Fehlerhafte Waehler-Id\n\r");
    return 0;
  }
  
  $sql="select queue_add(" . $matr . ", \'" . $buchst . "\', " . $bibnr . ", \'\{";
  $sql.=join(", ", @_) . "\}\')";
  $res=$dbconn->exec($sql);
  if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
    print("-65534 ", $dbconn->errorMessage, "\n\r");
    }
  else {
    @row=$res->fetchrow();
    print($row[0] . "\n\r");
    }
  
  return 0;
  }

sub commit_queue_element {
	my $voter=shift(@_);
	my ($sql, $res, $row, $matr, $buchst, $bibnr);

	($matr, $buchst)=splitid($voter);
	parerror() if(not defined $matr);
	#print("M: " . $matr . "\n");
  
	$sql="select waehlt(" . $matr . ", \'" . $buchst . "\', \'\{";
  $sql.=join(", ", @_) . "\}\')";
	$res=$dbconn->exec($sql);
	if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
		print("-65534 ", $dbconn->errorMessage, "\n\r");
		}
	else {
		@row=$res->fetchrow();
		print($row[0] . "\n\r");
		}

	return 0;
	}


sub delete_queue_element {
	my $voter=$_[0];
	my ($sql, $res, $row, $matr, $buchst);

	($matr, $buchst)=splitid($voter);
	parerror() if(not defined $matr);

	$sql="select queue_remove(" . $matr . ", \'" . $buchst . "\')";
	$res=$dbconn->exec($sql);
	if(not ($res->resultStatus eq PGRES_TUPLES_OK)) {
		print("-65534 ", $dbconn->errorMessage, "\n\r");
		}
	else {
		@row=$res->fetchrow();
		print($row[0] . "\n\r");
		}

	return 0;
	}

sub forced_logout_handler {
	logout();
	print("-1023 Urne wurde durch eine andere Urne ausgeloggt. Bitte sofort den Wahlausschuss informieren!\n\r");
	exit(0);
}

