#!/usr/bin/perl -w
#
# Admin-Frontend fuer das elektronische Waehlerverzeichnis
#
# (c) 2002-2004 Christoph Moench-Tegeder <moench-tegeder@rz.uni-karlsruhe.de>
#               Peter Schlaile <Peter.Schlaile@stud.uni-karlsruhe.de>
#               Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>
#
# Published under GPL.
#
# Dieses Programm soll auf der Konsole des Waehlerverzeichnis-Servers
# laufen. Alle administrativen Aufgaben, vom Anlegen der Urnen bis zum
# Loeschen der Datenbank nach der Einspruchsfrist.
#
# Vorausgesetzte Perl-Module:
#  - Cdk (libcdk-perl)
#  - Pg  (zu PostgreSQL, libpgperl)
#  - Date::Manip (libdate-manip-perl)
#
#
# 2008-01-08, Bjoern Tackmann <bjoern.tackmann@stud.uni-karlsruhe.de>
# Erweiterung zum Einlesen der FriCard-Nummern zur Gueltigkeitspruefung

use strict;
use Cdk;
use Pg;
use Date::Manip;
Date_Init( "Language=German" );
use Text::Wrap;


my (@log_menu, @waehler_menu, @urnen_menu, @sonst_menu, @quit_menu);
my (@mliste, @mloc, $maininfowin, @infotext);
my ($menu, $selmenu, $selit, $selected, $globalstate, @r, $n);
my ($dbconn, $dbret);


$dbconn=Pg::connectdb("dbname=wahl");
$dbret=$dbconn->status;
if($dbret eq PGRES_CONNECTION_BAD) {
	die "PostgreSQL: " . $dbconn->errorMessage;
	}
$dbconn->exec("set datestyle to german");
Date_Init("Language=German", "DateFormat=German");


@log_menu=		("</5>Log                 <!5>",
				 "</5>Matrikel-Nr. suchen <!5>",
				 "</5>Urne suchen         <!5>",
				 "</5>Letzte 400 Eintraege<!5>"
				);

@waehler_menu=	("</5>Waehler   <!5>",
				 "</5>Zeigen    <!5>",
				 "</5>Bearbeiten<!5>",
				 "</5>Loeschen  <!5>"
				);

@urnen_menu=	("</5>Urnen    <!5>",
				 "</5>Aktiv       <!5>",
				 "</5>Deaktivieren<!5>",
				 "</5>Sperren     <!5>",
				 "</5>Statistik   <!5>"
				);

@sonst_menu=	("</5>Administrativa            <!5>",
				 "</5>Wahlen vorbereiten        <!5>",
				 "</5>Urne registrieren         <!5>",
				 "</5>Wahlen freigeben          <!5>",
                                 "</5>FriCard-Nummern einlesen  <!5>",
	                         "</5>FriCard-Nummern loeschen  <!5>",
		                 "</5><#HL(26)><!5>",
				 "</5>Vorbereitung zuruecksetzen<!5>",
				 "</5>Datenbank zuruecksetzen   <!5>",
				);

@quit_menu=		("</5>Ende<!5>",
				 "</5>Ende<!5>"
				);

@mliste=		(\@log_menu,
				\@waehler_menu,
				\@urnen_menu,
				\@sonst_menu,
				\@quit_menu
				);

@mloc=("LEFT", "LEFT", "LEFT", "LEFT", "RIGHT");

Cdk::init();
$menu=new Cdk::Menu('Menulist'=>\@mliste, 'Menuloc'=>\@mloc);


while(1) {
	Cdk::refreshCdkScreen();

	($selmenu, $selit)=$menu->activate();
	$selected=$mliste[$selmenu]->[$selit];

	if($selected=~"Matrikel-Nr. suchen") {
		matrikel_suchen();
		}
	elsif($selected=~"Urne suchen") {
		urne_suchen();
		}
	elsif($selected=~"Letzte 400 Eintraege") {
		log_viewer();
		}
	elsif($selected=~"Zeigen") {
		waehler_zeigen();
		}
	elsif($selected=~"Bearbeiten") {
		waehler_bearbeiten();
		}
	elsif($selected=~"Loeschen") {
		waehler_loeschen();
		}
	elsif($selected=~"Aktiv") {
		aktive_urnen();
		}
	elsif($selected=~"Deaktivieren") {
		urne_deaktivieren();
		}
	elsif($selected=~"Sperren") {
		urne_sperren();
		}
	elsif($selected=~"Statistik") {
		urnen_stats();
		}
	elsif($selected=~"Wahlen vorbereiten") {
		vorbereiten();
		}
	elsif($selected=~"Urne registrieren") {
		urnenmelden();
		}
	elsif($selected=~"Wahlen freigeben") {
		freigeben();
		}
	elsif($selected=~"Vorbereitung zuruecksetzen") {
		vorbereitung_zurueck();
		}
	elsif($selected=~"Datenbank zuruecksetzen") {
		datenbank_zurueck();
		}
	elsif($selected=~"Ende") {
		exit_dialog();
	        }
	elsif($selected=~"FriCard-Nummern einlesen") {
	        fricard_nummern_lesen();
	        }
        elsif($selected=~"FriCard-Nummern loeschen") {
	        fricard_nummern_loeschen();
         	}
	}

	
sub matrikel_suchen {
	my ($box, $ret, $sql);

	$box=new Cdk::Entry('Label'=>"</B>Matrikel-Nr: ", 'Max'=>8, 'Width'=>30);
	$ret=$box->activate();
	if(not defined $ret) {
		return;
		}
	
	if(not $ret=~/^\d+$/) {
		fehler("Keine Matrikelnummer");
		return;
		}

	$sql="select vlog_matr, vlog_buchst, vlog_date, vlog_urne, vlog_lev, vlog_text, vlog_client ";
	$sql.="from v_log where vlog_matr = $ret order by vlog_nr";
	logwin("Log fuer Matrikel-Nr. $ret", $sql);

	return;
	}


sub urne_suchen {
	my ($box, $ret, $sql);
	
	$box=new Cdk::Entry('Label'=>"</B>Urnen-Kennung: ", 'Max'=>8, 'Width'=>30);
	$ret=$box->activate();
	if(not defined $ret) {
		return;
		}

	if(not $ret=~/^[a-z]+\d*$/) {
		fehler("Keine Urnenkennung");
		return;
		}

	$sql="select vlog_matr, vlog_buchst, vlog_date, vlog_urne, vlog_lev, vlog_text, vlog_client ";
	$sql.="from v_log where vlog_urne = \'$ret\' order by vlog_nr";
	logwin("Log fuer Urne $ret", $sql);

	return;
	}


sub log_viewer {
	my $sql;

	$sql="select vlog_matr, vlog_buchst, vlog_date, vlog_urne, vlog_lev, ";
	$sql.="vlog_text, vlog_client from v_log order by vlog_nr desc limit 400";
	logwin("Komplett-Log", $sql);

	return;
	}


sub waehler_zeigen {
	my (@ctitle, @rtitle, @cw, @ctype, @mtext);
	my ($matrix, $r, $c, $i, $sql, $matr, $buchst);
	my ($dbr, @row, $win, @liste);

	($matr, $buchst)=aq_waehler_id("Waehlersuche");
	return if(not defined $matr);
	
	$sql="select * from t_waehler where waehler_matr = $matr ";
	$sql.="and waehler_buchst = \'$buchst\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler($dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples<1) {
		fehler("Datensatz nicht gefunden");
		return;
		}

	$sql="select vhat_nr, vhat_wahl from v_hat where vhat_matr = $matr order by vhat_nr";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler($dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples<1) {
		fehler("Waehler hat bisher nicht gewaehlt");
		return;
		}

	while(@row=$dbr->fetchrow()) {
		push(@liste, join(' ', ($row[0], $row[1])));
		}

	$win=new Cdk::Scroll('Title'=>"<C>Abgegebene Stimmen $matr", 'List'=>\@liste, 'Numbers'=>0, 'Height'=>15, 'Width'=>35);
	$win->activate();

	return;
	}


sub waehler_bearbeiten {
	my ($selwin, @wahlen, @cl, @hat, @rt);
	my ($okwin, @msg, @bl, $pick);
	my ($sql, $dbr, $matr, $buchst, $x, $str, @set);

	($matr, $buchst)=aq_waehler_id("Waehler bearbeiten");
	return if(not defined $matr);

	$sql="select wahl_nr, wahl_name from t_wahlen order by wahl_nr";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}

	while(@r=$dbr->fetchrow()) {
		push(@wahlen, $r[1]);
		push(@hat, 1);
		}

	$sql="select * from t_waehler where waehler_matr = $matr ";
	$sql.="and waehler_buchst = \'$buchst\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler($dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples<1) {
		fehler("Datensatz nicht gefunden");
		return;
		}

	$sql="select hat_wahl from t_hat where hat_matr = $matr";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}

	while(@r=$dbr->fetchrow()) {
		$hat[$r[0]-1]=0;
		}
		
	@cl=("</24>Hat<!24>", "</16>Nicht<!16>");

	$selwin=new Cdk::Selection('Title'=>"<C>Wahlen von ". $matr . $buchst, 'List'=>\@wahlen, 'Choices'=>\@cl, 'Height'=>15, 'Width'=>40);
	# Actung, die Cdk-Doku sagt, dass der Parameter Defaults heissen wuerde
	# Der Source gibt den Hinweis auf Choices.
	$selwin->set('Choices'=>\@hat, 'Highlight'=>"A_REVERSE");
	@rt=$selwin->activate();

	if(not defined $rt[0]) {
		meldung("Vorgang abgebrochen");
		return;
		}

	for($x=0; $x<=$#rt; $x++) {
		if($cl[$rt[$x]]=~"Hat") {
			push(@set, $x+1);
			}
		}

	@msg=("<C>Bitte bestaetigen", "<C>Setzen der Waehler-Attribute bei " . $matr . $buchst, "<C>auf @set");
	@bl=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@bl);
	$pick=$okwin->activate();
	if(not defined $pick) {
		meldung("Vorgang abgebrochen");
		return;
		}
	if($bl[$pick]=~"Nein") {
		meldung("Vorgang abgebrochen");
		return;
		}

	$sql="select set_waehler_attr($matr, \'$buchst\', \'{";
	$sql.=join(', ', @set);
	$sql.="}\')";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Vorgang fehlgeschlagen: " . $dbconn->errorMessage);
		return;
		}

	@r=$dbr->fetchrow();
	if($r[0] eq 'f') {
		fehler("Waehler existiert nicht");
		return;
		}

	meldung("Aenderung erfolgreich");
	
	return;
	}


sub waehler_loeschen {
	my (@ctitle, @rtitle, @cw, @ctype, @mtext, @msg, @buttons);
	my ($matrix, $okwin, $pick, $r, $c, $i, $sql, $matr, $buchst);
	my ($dbr, @row, $win);

	($matr, $buchst)=aq_waehler_id("Waehler-ID loeschen");
	return if(not defined $matr);

	@msg=("<C>Bitte bestaetigen", "<C>Loeschen der Waehler-ID " . $matr . $buchst);
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		fehler("Waehler-ID nicht geloescht");
		return;
		}
	if($buttons[$pick]=~"Nein") {
		fehler("Waehler-ID nicht geloescht");
		return;
		}

	$sql="select * from t_waehler where waehler_matr = $matr ";
	$sql.="and waehler_buchst=\'$buchst\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Datenbankfehler: " . $dbconn->errorMessage);
		return;
		}

	if($dbr->ntuples<1) {
		fehler("Waehler-ID ". $matr .$buchst . " existiert nicht");
		return;
		}

	$sql="delete from t_waehler where waehler_matr = $matr and waehler_buchst=\'$buchst\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_COMMAND_OK) {
		fehler("Waehler-ID " . $matr . $buchst . "nicht geloescht: " . $dbconn->errorMessage);
		return;
		}
	meldung("Waehler-ID " . $matr . $buchst . " geloescht");

	return;
	}



sub aktive_urnen {
	my ($sql, $dbr, @row, @liste, $line, $win);
	
	$sql="select client_urne, client_ip, date_trunc(\'second\', client_start) ";
	$sql.="from t_clients order by client_urne";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler($dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples<1) {
		fehler("Derzeit keine aktiven Urnen");
		return;
		}
	
	while(@row=$dbr->fetchrow()) {
		push(@liste, join(' ', @row));
		}

	$win=new Cdk::Scroll('Title'=>"<C>Aktive Urnen", 'List'=>\@liste, 'Numbers'=>0, 'Height'=>15, 'Width'=>44);
	$win->activate();

	return;
	}


sub urne_sperren {
	my ($textwin, $okwin, $sql, $dbr, $urne, $ret);
	my (@msg, @buttons, $pick);

	$textwin=new Cdk::Entry('Label'=>"</B>Urnen-Kennung: ", 'Max'=>8, 'Width'=>30);
	$urne=$textwin->activate();
	if(not defined $urne) {
		return;
		}

	if(not $urne=~/^[a-z]+\d*$/) {
		fehler("Keine Urnenkennung");
		return;
		}

	undef($textwin);

	@msg=("<C>Bitte bestaetigen", "<C>Sperren der Urne $urne");
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		fehler("Urne $urne nicht gesperrt");
		return;
		}
	if($buttons[$pick]=~"Nein") {
		fehler("Urne $urne nicht gesperrt");
		return;
		}

	$sql="select * from t_urnen where urne_name=\'$urne\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Datenbankfehler: " . $dbconn->errorMessage);
		return;
		}

	if($dbr->ntuples<1) {
		fehler("Urne $urne existiert nicht");
		return;
		}

	$sql="update t_urnen set urne_broken='true' where urne_name=\'$urne\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_COMMAND_OK) {
		fehler("Urne $urne nicht gesperrt: " . $dbconn->errorMessage);
		return;
		}
	meldung("Urne $urne gesperrt");

	return;
	}


sub urne_deaktivieren {
	my ($textwin, $okwin, $sql, $dbr, $urne, $ret);
	my (@msg, @buttons, $pick);

	$textwin=new Cdk::Entry('Label'=>"</B>Urnen-Kennung: ", 'Max'=>8, 'Width'=>30);
	$urne=$textwin->activate();
	if(not defined $urne) {
		return;
		}

	if(not $urne=~/^[a-z]+\d*$/) {
		fehler("Keine Urnenkennung");
		return;
		}

	undef($textwin);

	@msg=("<C>Bitte bestaetigen", "<C>Deaktivieren der Urne $urne");
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		fehler("Urne $urne nicht deaktiviert");
		return;
		}
	if($buttons[$pick]=~"Nein") {
		fehler("Urne $urne nicht deaktiviert");
		return;
		}

	$sql="select * from t_clients where client_urne=\'$urne\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Datenbankfehler: " . $dbconn->errorMessage);
		return;
		}

	if($dbr->ntuples<1) {
		fehler("Urne $urne ist nicht aktiv");
		return;
		}

	$sql="delete from t_clients where client_urne=\'$urne\'";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_COMMAND_OK) {
		fehler("Urne $urne nicht deaktiviert: " . $dbconn->errorMessage);
		return;
		}
	meldung("Urne $urne deaktiviert");

	return;
	}


sub urnen_stats {
	my ($sql, $dbr, $win, @row, $line, @liste);

	$sql="select urne_name, urne_wer, urne_inhalt, urne_broken from t_urnen order by urne_inhalt";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Datenbank: " . $dbconn->errorMessage);
		return;
		}

	if($dbr->ntuples<1) {
		fehler("Keine Urnen erfasst");
		return;
		}

	while(@row=$dbr->fetchrow()) {
		$line=sprintf('%s%10s %30s %d', $row[3] eq "t" ? "#" : " ", $row[0], $row[1], $row[2]);
		push(@liste, $line);
		}

	$win=new Cdk::Scroll('Message'=>'<C>Urnen-Uebersicht', 'List'=>\@liste, 'Numbers'=>0, 'Height'=>15, 'Width'=>60);
	$win->activate();
	
	return;
	}


sub vorbereiten {
	my (@urnenzeiten, @wahlen);
	my ($sql, $dbr, $wza, $wze, $wstr);

	@urnenzeiten=vorb_zeiten();
	return if(not defined $urnenzeiten[0]);
		
	@wahlen=vorb_wahlen();
	return if(not defined $wahlen[0]);

	$wza="\"" . shift(@urnenzeiten) . "\"";
	$wze="\"" . shift(@urnenzeiten) . "\"";
	while($#urnenzeiten>=1) {
		$wza.=", \"" . shift(@urnenzeiten) . "\"";
		$wze.=", \"" . shift(@urnenzeiten) . "\"";
		}

	$wstr="\"" . join("\", \"", @wahlen) . "\"";
	$sql="select vorbereitung(\'{";
	$sql.=$wza . "}\', \'{" . $wze . "}\', \'{" . $wstr . "}\')";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Initialisierung fehlgeschlagen: " . $dbconn->errorMessage);
		return;
		}

	meldung("Initialisierung erfolgreich");

	return;
	}

sub urnenmelden {
        my $mtitle="Urne registrieren";
	my (@ctitle, @rtitle, @cw, @ctype, @mtext);
	my ($matrix, $sql, $r, $c, $i, $matr, $buchst);

	@ctitle=("Urnenname", "fuer");
	@rtitle=("");
	@cw=(10, 10);
	@ctype=("MIXED", "MIXED");
	@mtext=(["", ""]);
	
	$matrix=new Cdk::Matrix('Title'=>"<C>$mtitle",
				'RowTitles'=>\@rtitle,
				'ColTitles'=>\@ctitle,
				'ColWidths'=>\@cw,
				'ColTypes'=>\@ctype,
				'Vrows'=>1, 'Vcols'=>2);
	# $matrix->set('Values'=>\@mtext);
	($r, $c, $i)=$matrix->activate();
	return if(not defined $r);

	my ($urne, $wer)= ($i->[0][0], $i->[0][1]);

	if(not $urne=~/^[a-zA-Z0-9]+$/) {
	    fehler("Ungueltige Zeichen in der Urnenkenung\n");
	    return;
	}
	if(not $wer=~/^[a-zA-Z0-9.,:\/\-()@\s]+$/) {
	    fehler("Ungueltige Zeichen im Betreuertext\n");
	    return;
	}

	$dbconn=Pg::connectdb("dbname=wahl");
	$r=$dbconn->status;
	if($r eq PGRES_CONNECTION_BAD) {
	    fehler("Postgres: " . $dbconn->errorMessage . "\n");
	    return;
	}

	$sql="select register_urne(\'" . $urne . "\', \'" . $wer . "\')";
	$r=$dbconn->exec($sql);
	if(not $r->resultStatus eq PGRES_TUPLES_OK) {
	    fehler("PostgreSQL: " . $dbconn->errorMessage . "\n");
	    return;
	}

	@r=$r->fetchrow();
	if($r[0] ne 't') {
	    fehler("Fehler beim Registrieren, Details im Log\n");
	}

	$dbconn->reset();
    }


sub freigeben {
	my ($sql, $dbr, $err, $n);
	my (@buttons, @msg, $okwin, $pick);
	my ($fsel, $fname);

	$sql="select count(urne_name) from t_urnen";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}
	@r=$dbr->fetchrow();
	if($r[0]==0) {
		fehler("Keine Urnen definiert");
		return;
		}

	@msg=("<C>Betriebsmodus",
	      "A: Liste der Wahlberechtigen einlesen",
		  "B: Datenbank wird bei der Wahl aufgebaut"
		 );

	@buttons=("B", "A");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();
	return if(not defined $pick);
	if($buttons[$pick]=~"A") {
		undef($okwin);
		$fsel=new Cdk::Fselect('Label'=>"Waehlerliste:", 'Height'=>20, 'Width'=>50, 'Dattrib'=>"</16/B>", 'Lattrib'=>"</39>", 'Fattrib'=>"</40>");
		$fname=$fsel->activate();
		if(not defined $fname) {
			message("Vorgang abgebrochen");
			return;
			}

		$err=0;
		open(LISTE, "<" . $fname) or $err=1;
		if($err==1) {
			fehler("Datei " . $fname . "nicht lesbar");
			return;
			}

		undef($fname);

		# Transaktion, halbe Liste ist nicht gut
		# Ausserdem werden wir hiermit Autocommit los (Performance!)
		$dbconn->exec("begin");
		$n=0;
		while(<LISTE>) {
			chomp;
			if(/^([\d+])\s+([a-zA-Z]{2})$/) {
				$sql="insert into t_waehler (waehler_matr, waehler_buchst)";
				$sql.=" values (" . $1 . ", \'" . uc($2) . "\')";
				$dbr=$dbconn->exec($sql);
				if(not $dbr->resultStatus eq PGRES_COMMAND_OK) {
					fehler("PostgreSQL: " . $dbconn->errorMessage);
					# Abbruch
					$dbconn->exec("rollback");
					return;
					}
				$n++;
				}
			}
		# Jetzt schreiben
		$dbconn->exec("commit");
		message("$n Waehler eingelesen");
	
		$sql="insert into t_plan (plan) values ('A')";
		}
	else {
		$sql="insert into t_plan (plan) values ('B')";
		}

	$dbconn->exec($sql);

	return;
	}


sub vorbereitung_zurueck {
	my ($sql, $dbr);
	my (@buttons, @msg, $okwin, $pick);

	$sql="select plan from t_plan limit 1";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples>0) {
		fehler("Ruecksetzen derzeit nicht moeglich");
		return;
		}

	@msg=("<C>Bitte bestaetigen", "<C>Datenbank zuruecksetzen");
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		return;
		}
	if($buttons[$pick]=~"Nein") {
		return;
		}

	$sql="select reset_vorb()";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}

	@r=$dbr->fetchrow();
	if($r[0] eq 'f') {
		fehler("Ruecksetzen derzeit nicht moeglich");
		return;
		}

	meldung("Vorbereitungen erfolgreich zuruecksetzen");

	return;
	}

sub datenbank_zurueck {
	my ($sql, $dbr);
	my (@buttons, @msg, $okwin, $pick);

	@msg=("<C>Bitte bestaetigen", "<C>Datenbank komplett zuruecksetzen",
	      "<C></B>KEINE SICHERHEITSCHECKS!<!B>",
	      "<C></B>ALLE DATEN WERDEN GELOESCHT!<!B>");
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		return;
		}
	if($buttons[$pick]=~"Nein") {
		return;
		}

	$sql="select reset_db()";
	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("PostgreSQL: " . $dbconn->errorMessage);
		return;
		}

	@r=$dbr->fetchrow();
	if($r[0] eq 'f') {
		fehler("Fehler beim Zuruecksetzen aufgetreten");
		return;
		}

	meldung("Datenbank erfolgreich zurueckgesetzt");

	return;
	}


sub exit_dialog {
	my (@buttons, @msg, $okwin, $pick);

	@msg=("<C>Bitte bestaetigen", "<C>Beenden");
	@buttons=("Nein", "Ja");
	$okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
	$pick=$okwin->activate();

	if(not defined $pick) {
		return;
		}
	if($buttons[$pick]=~"Nein") {
		return;
		}

	Cdk::end();

	exit(0);
	}


sub fehler {
	my ($msgwin, $r);
	my @msgtext;

	$Text::Wrap::columns = 50;
	@msgtext=("<C>Fehler", "", split( /\n/, wrap('<C>', '<C>', $_[0])));
	$msgwin=new Cdk::Label('Message'=>\@msgtext, 'Box'=>"TRUE");
	$msgwin->draw();
	$msgwin->wait();
	
	return;
	}


sub meldung {
	my ($msgwin, $r);
	my @msgtext;

	$Text::Wrap::columns = 50;
	@msgtext=("<C>Meldung", "", split( /\n/, wrap('<C>', '<C>', $_[0])));
	$msgwin=new Cdk::Label('Message'=>\@msgtext, 'Box'=>"TRUE");
	$msgwin->draw();
	$msgwin->wait();
	
	return;
	}


sub vorb_zeiten {
	my ($wdscale, $ntage, @wzeiten);
	my ($dmatrix, @ctitle, @rtitle, @cwidth, @ctype);
	my ($r, $c, $val, $i, $j, $date);

	$wdscale=new Cdk::Scale('Label'=>"Wieviele Wahltage : ", 'Width'=>30, 'Low'=>1, 'High'=>30);
	$ntage=$wdscale->activate();
	return if(not defined $ntage);

	undef($wdscale);

	@ctitle=("Datum", "Anfang", "Ende");
	@ctype=("MIXED", "MIXED", "MIXED");
	@cwidth=(15, 15, 15);
	for($i=1; $i<=$ntage; $i++) {
		push(@rtitle, "$i. Tag");
		}

	$dmatrix=new Cdk::Matrix('Title'=>"<C>Urnenzeiten", 'RowTitles'=>\@rtitle, 'ColTitles'=>\@ctitle, 'ColWidths'=>\@cwidth, 'ColTypes'=>\@ctype, 'Vrows'=>min($ntage, 15), 'Vcols'=>3);

	# Ich habe wirklich keine Ahnung, warum der folgende Code
	# funktioniert, aber er tut's
	if ($ntage > 1) {
	    my @vals;
	    for $i (0 .. $ntage-1) {
		my $date_i = DateCalc( "heute", "+ $i Tage" );
		push @vals, [ scalar UnixDate( $date_i, "%d.%m.%Y" ),
			      '07:00', '20:00', ('foo')x($ntage-2) ];
	    }
	    $dmatrix->set( Values => \@vals );
	}

	($r, $c, $val)=$dmatrix->activate();
	return if(not defined $r);

	for($i=0; $i<$r; $i++) {
		# Doppelte Verwendung von $val->[$x][0] ist Absicht, so werden
		# spaeter vollwertige Timestamps konstruiert
		push(@wzeiten, $val->[$i][0] . " " . $val->[$i][1]);
		push(@wzeiten, $val->[$i][0] . " " . $val->[$i][2]);
		}
	
	# Ist das Datum sinnvoll? Pruefung mit Funktionen aus Date::Manip,
	# der Parser ist besser als jeder, den ich hier entwickeln wuerde.
	# Die Pruefung findet nach dem Zusammensetzen der Daten statt,
	# da ja die Zusammensetzung der Datenbank vorgeworfen wird (und
	# genau da muss das gueltige Datum erscheinen)
	for($i=0; $i<$#wzeiten; $i++) {
		$date=ParseDate($wzeiten[$i]);
		if(not defined $date) {
			fehler("Ungueltiges Datum/Zeit in der Liste");
			return;
			}
		}

	return @wzeiten;
	}


sub vorb_wahlen {
	my ($wscale, $nwahlen, @wahlen);
	my ($wmatrix, @ctitle, @rtitle, @cwidth, @ctype);
	my ($r, $c, $val, $i, $ntage);

	$wscale=new Cdk::Scale('Label'=>"Wieviele Wahlen : ", 'Width'=>30, 'Low'=>1, 'High'=>30);
	$nwahlen=$wscale->activate();
	return if(not defined $nwahlen);

	# undef($wscale);

	@ctitle=("Beschreibung");
	@ctype=("MIXED");
	@cwidth=(45);
	for($i=1; $i<=$nwahlen; $i++) {
		push(@rtitle, "$i. Wahl");
		}

	$wmatrix=new Cdk::Matrix('Title'=>"<C>Wahlbezeichnungen", 'RowTitles'=>\@rtitle, 'ColTitles'=>\@ctitle, 'ColWidths'=>\@cwidth, 'ColTypes'=>\@ctype, 'Vrows'=>min($nwahlen, 15), 'Vcols'=>1);

	($r, $c, $val)=$wmatrix->activate();
	return if(not defined $r);
	for($i=0; $i<$r; $i++) {
		# Test auf "boesartige" Zeichen in der Beschreibung, also werden nur
		# [a-zA-Z0-9.,:/()@ ] zugelassen, das muss fuer eine Wahlbeschreibung
		# reichen und tut der Datenbank nicht weh.
		if(not $i=~/^[a-zA-Z0-9.,:\/()@\s]+$/) {
			fehler("Ungueltige Zeichen in der Wahlbeschreibung");
			return;
			}

		push(@wahlen, $val->[$i][0]);
		}

	return @wahlen;
	}


sub aq_waehler_id {
	my $mtitle=$_[0];
	my (@ctitle, @rtitle, @cw, @ctype, @mtext);
	my ($matrix, $r, $c, $i, $matr, $buchst);

	@ctitle=("Matrikel-Nr.", "Buchstaben");
	@rtitle=("Waehler-ID");
	@cw=(10, 4);
	@ctype=("INT", "CHAR");
	@mtext=(["", ""]);
	
	$matrix=new Cdk::Matrix('Title'=>"<C>$mtitle", 'RowTitles'=>\@rtitle, 'ColTitles'=>\@ctitle, 'ColWidths'=>\@cw, 'ColTypes'=>\@ctype, 'Vrows'=>1, 'Vcols'=>2);
	# $matrix->set('Values'=>\@mtext);
	($r, $c, $i)=$matrix->activate();
	return if(not defined $r);

	if((not $i->[0][0]=~/^\d+$/) or (not $i->[0][1]=~/^[a-zA-Z]{2}$/)) {
		fehler("Keine gueltige Waehler-ID");
		return;
		}

	($matr, $buchst)=($i->[0][0], uc($i->[0][1]));

	return ($matr, $buchst);
	}


sub logwin {
	my ($title, $sql)=($_[0], $_[1]);
	my ($dbr, $line, $win, $ret);
	my (@row, @retlist);


	$dbr=$dbconn->exec($sql);
	if(not $dbr->resultStatus eq PGRES_TUPLES_OK) {
		fehler("Datenbankfehler: " . $dbconn->errorMessage);
		return;
		}
	if($dbr->ntuples eq 0) {
		fehler("Keinen passenden Eintrag gefunden");
		return;
		}

	while(@row=$dbr->fetchrow()) {
		$line=sprintf('%8d %2s %7s  %8s  %20s  %16s', $row[0], $row[1], join("  ", ($row[2], $row[3])), $row[4], $row[5], $row[6]); 
		push(@retlist, $line);
		}

	$win=new Cdk::Scroll('Title'=>$title, 'List'=>\@retlist, 'Numbers'=>0, 'Height'=>15, 'Width'=>76);
	$ret=$win->activate();

	return;
	}


sub min {
	my ($a, $b)=($_[0], $_[1]);

	return ($a < $b ? $a : $b);
	}


sub fricard_nummern_lesen {
    my $box = new Cdk::Entry('Label' => "</B>CSV-Datei von der Verwaltung: ", 'Max'=>127, 'Width'=>30);
    my $ret = $box->activate();
    return unless defined $ret;
	
     unless (defined open FILE, qq/<$ret/) {
 	fehler(q/Kann die Datei nicht oeffnen!/);
 	return;
     }

     my $dbret = $dbconn->exec(q/SELECT clearbibnummern()/);
     unless ($dbret->resultStatus eq PGRES_TUPLES_OK) {
 	fehler(q/Kann Bibnummern nicht loeschen!/);
 	return;
     }

     my @lines;
     @lines = <FILE>;
     close FILE;

     my $errcnt = 0;
     my $cnt = 0;
     foreach (@lines) {
 	next unless m/"(\d+)\s*";"(\d+)\s*"/;
 	$dbret = $dbconn->exec(qq/INSERT INTO t_bibnummern (bib_nummer) VALUES ($1)/);
 	if ($dbret->resultStatus eq PGRES_COMMAND_OK) {
 	    $cnt++;
 	} else {
 	    $errcnt++;
 	}
     }

     if ($errcnt == 0) {
 	meldung(qq/$cnt Datensaetze erfolgreich importiert./);
     } else {
 	fehler(qq/$errcnt Fehler aufgetreten!/);
     }
    
    return;
}

sub fricard_nummern_loeschen {
    my @msg=("<C>Bitte bestaetigen", "<C>FriCard-Nummern Loeschen");
    my @buttons=("Nein", "Ja");
    my $okwin=new Cdk::Dialog('Message'=>\@msg, 'Buttons'=>\@buttons);
    my $pick=$okwin->activate();

    if(not defined $pick) {
	return;
    }

    if($buttons[$pick]=~"Ja") {
     my $dbret = $dbconn->exec(q/SELECT clearbibnummern()/);
     unless ($dbret->resultStatus eq PGRES_TUPLES_OK) {
	 fehler(q/Kann Bibnummern nicht loeschen!/);
	 return;
    }
 }
}

