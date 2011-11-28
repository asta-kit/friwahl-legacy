<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

require("../web/dbconfig.php") ;
require("../web/querysys.php") ;
require("../web/util.php") ;

function show_kandidaten_status ( $txt ) {
	print ( "\\subsubsection*{".$txt."}\n".
		"\\begin{tabular}{lr}\n".
		"Kandidierende & Stimmen \\\\\\hline\n" ) ;
}


function show_kandidaten ( $row, &$cnt ) {
	extract ( $row ) ;
	if ( $_liste_id ) {
		print "\\subsection*{Liste: ".
			listname($liste_name_kurz,$liste_name_lang)."}\n" ;
		$cnt = 0 ;
	}
	if ( $_status || $_liste_id ) {
		switch ( $status ) {
		case 1:
			show_kandidaten_status ( "Gewählt" ) ;
			break ;
		case 2:
			show_kandidaten_status ( "Los \\footnotemark{(*)}" ) ;
			break ;
		case 3:
			show_kandidaten_status ( 
				$cnt == 0 ? "Nicht gewählt" : 
				"Nachrückende / Nicht gewählt" ) ;
			break ;
		}
	}

	switch ( $kandidat_typ ) {
	case 0:
	case 1:
		print "$kandidat_vorname $kandidat_nachname" ;
		break ;
	case 2:
		print "Nein" ;
		break ;
	}
	
	print "& $stimmen \\\\\n" ;
	$cnt++ ;
	
	if ( $status_ || $liste_id_ ) {
		print "\hline\\end{tabular}\n" ;
	}
}

function show_listen ( $row ) {
	extract ( $row ) ;
	print ( listname($name_kurz,$name_lang). " & $stimmen & ".
		percent($stimmen,$summe)."\% & $hoechstzahl & $sitze &".
		($los> 0 ? "(+1)" : "").
		"\\\\\n" ) ;
}

function show_wahlen ( $row ) {
	extract ( $row ) ;

	$listen_gueltig = $stimmen_gesamt - $stimmzettel_ungueltig - $listen_ungueltig ;
	$listen_summe = $listen_gueltig - $listen_enthaltungen ;
	$kandidaten_gueltig = $stimmen_gesamt - $stimmzettel_ungueltig - $kandidaten_ungueltig ;
	$kandidaten_summe = $kandidaten_gueltig - $kandidaten_enthaltungen ;

	print "\\section{Wahl zum $wahl_name}\n" ;

	if ( simple_query ( "SELECT count(*) FROM liste ".
			    "WHERE wahl = $wahl_id" ) > 1 ) {
		print "\\subsection*{Listenstimmen}\n" ;

		// Gesamt-Informationen
		print ( "Wahlberechtigte: $wahlberechtigt, ".
			"abgegebene Stimmzettel: $stimmen_gesamt, ".
			"Wahlbeteiligung: ".
			percent($stimmen_gesamt,$wahlberechtigt)."\%".
			"\n\n".
			"ungültige Stimmzettel: $stimmzettel_ungueltig, ".
			"ungültige Stimmen: $listen_ungueltig ".
			"gültige Stimmen: $listen_gueltig, ".
			"\n\n".
			"Enthaltungen: $listen_enthaltungen ".
			"\n\n" ) ;

		print ( "\\begin{tabular}{lrrrrl}\n".
			"Liste & Stimmen & Anteil & Quote & Sitze & \\\\\\hline\n" ) ;
		// Listen-Tabelle
		do_query ( 
			"SELECT liste.name_kurz, liste.name_lang, ".
			"anzeige_red as r, anzeige_green as g, ".
			"anzeige_blue as b, ".
			"hoechstzahl, sitze, los, ".
			"sum(liste_urne.stimmen) AS stimmen, ".
			"$listen_summe AS summe ".
			"FROM liste, urne, liste_urne ".
			"WHERE liste.id = liste_urne.liste ".
			"AND urne.id = liste_urne.urne ".
			"AND urne.status = ".$GLOBALS["ok_status"]." ".
			"AND wahl = $wahl_id ".
			"GROUP BY liste.id ".
			"ORDER by liste.nummer", 
			show_listen ) ;
		print "\\hline\\end{tabular}\n\n" ;
		$num_los = simple_query ( "SELECT los FROM liste ".
					  "WHERE wahl = $wahl_id ".
					  "AND los > 0" ) ;
		if ( $num_los > 0 ) {
			print ( "(+1): ggf. +1 von $num_los Restsitzen ".
				"per Los\n\n" ) ;
		}
	}
	
	// Kandidaten
	print "\\subsection*{Kandidierendenstimmen}\n" ;

	// Gesamt-Daten
	print ( "Wahlberechtigte: $wahlberechtigt, ".
		"abgegebene Stimmzettel: $stimmen_gesamt, ".
		"Wahlbeteiligung: ".percent($stimmen_gesamt,
					    $wahlberechtigt)."\%".
		"\n\n".
		"ungültige Stimmzettel: $stimmzettel_ungueltig, ".
		"ungültige Stimmen: $kandidaten_ungueltig, ".
		"gültig: $kandidaten_gueltig ".
		"\n\n" ) ;
	if ( $max_stimmen_wert == 1 ) {
		print ( "Enthaltungen: $kandidaten_enthaltungen ".
			"\n\n" ) ;
	}
	
	// Kandidaten
	do_query ( "SELECT liste.id AS liste_id, ".
		   "liste.name_kurz AS liste_name_kurz, ".
		   "liste.name_lang AS liste_name_lang, ".
		   "anzeige_red AS r, ".
		   "anzeige_green AS g, ".
		   "anzeige_blue AS b, ".
		   "kandidat.typ AS kandidat_typ, ".
		   "kandidat.status AS status, ".
		   "kandidat.vorname AS kandidat_vorname, ".
		   "kandidat.nachname AS kandidat_nachname, ".
		   "sum(kandidat_urne.stimmen) AS stimmen ".
		   "FROM liste, kandidat, urne, kandidat_urne ".
		   "WHERE kandidat.id = kandidat_urne.kandidat ".
		   "AND urne.id = kandidat_urne.urne ".
		   "AND liste.id = kandidat.liste ".
		   "AND urne.status = ".$GLOBALS["ok_status"]." ".
		   "AND liste.wahl = $wahl_id ".
		   "GROUP BY kandidat.id ".
		   "ORDER BY liste.nummer, liste.id, status, stimmen DESC, ".
		   "kandidat.listenplatz",
		   show_kandidaten ) ;
	if ( $num_los != 0 ) {
		print ( "\\footnotemark{(*)} $num_los Restsitze werden per ".
			"Los auf die gekennzeichneten Listen verteilt.\n\n" ) ;
	}
}

?>
\documentclass{article}
\usepackage{a4wide}
\usepackage[latin1]{inputenc}
\usepackage[ngerman]{babel}
\usepackage{wahead}
\parindent=0pt
\begin{document}
\wahead
\begin{center}
\bfseries\Huge Ergebnisse der Wahlen zum Unabhängigen Modell
\end{center}

<?php
do_query ( "SELECT ".
	   "wahl.id as wahl_id, wahl.name_lang as wahl_name, ".
	   "wahlberechtigt, sitze_wert, max_stimmen_wert, ".
	   "sum(stimmzettel) as stimmen_gesamt, ".
	   "sum(stimmzettel_ungueltig) as stimmzettel_ungueltig, ".
	   "sum(listen_ungueltig) as listen_ungueltig, ".
	   "sum(listen_enthaltungen) as listen_enthaltungen, ".
	   "sum(kandidaten_ungueltig) as kandidaten_ungueltig, ".
	   "sum(kandidaten_enthaltungen) as kandidaten_enthaltungen ".
	   "FROM wahl, urne, wahl_urne ".
	   "WHERE wahl.id = wahl_urne.wahl ".
	   "AND urne.id = wahl_urne.urne ".
	   "AND status = ".$GLOBALS["ok_status"]." ".
	   "GROUP by wahl.id ".
	   "ORDER by wahl.name_lang", 
	   show_wahlen ) ;
?>
\end{document}
