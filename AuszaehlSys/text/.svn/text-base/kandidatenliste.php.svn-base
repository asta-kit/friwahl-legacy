<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

require("../web/dbconfig.php") ;
require("../web/querysys.php") ;
require("../web/util.php") ;

function candidate ( $name, $extra, $platz ) {
	echo '\candidate{'.$name.'}{'.$extra.'}{'.$platz."}\n";
}

function do_row ( $row ) {
	extract ( $row ) ;

	if ( isset($_wahl_id) ) {
		echo 
			'\begin{election}{'.
			'Election={'.$wahl_name.'},'.
			'CandidateVotes='.$wahl_max_stimmen.','.
			'MaxCumulate='.$wahl_max_kumulieren.','.
			($wahl_panaschieren ? 'CrossList' : 'NoCrossList' ).
			"}\n" ;
	}
	
	if ( isset($_liste_id) ) {
		echo '\begin{party}{'.$liste_kurz.'}{'.$liste_lang.'}'.
			'{'.$liste_nummer."}\n" ;
	}
	
	switch ( $kandidat_typ ) {
	case 0:
		candidate("$kandidat_vorname $kandidat_nachname",
			  $kandidat_extra, $kandidat_listenplatz ) ;
		break ;
	case 1:
		yes_handler ( "$kandidat_vorname $kandidat_nachname",
			      $kandidat_extra, $kandidat_listenplatz ) ;
		break ;
	case 2:
		no_handler ( "$kandidat_vorname $kandidat_nachname",
			     $kandidat_extra, $kandidat_listenplatz ) ;
		break ;
	}
	
	if ( isset($liste_id_) ) {
		echo "\\end{party}\n" ;
	}
	
	if ( isset($wahl_id_) ) {
		echo "\\end{election}\n" ;
	}
}

function kandidatenliste() {
  do_query ( "SELECT ".
	     "wahl.id                  AS wahl_id,".
	     "wahl.name_lang           AS wahl_name,".
	     "wahl.max_stimmen_wert    AS wahl_max_stimmen,".
	     "wahl.max_kumulieren_wert AS wahl_max_kumulieren,".
	     "wahl.panaschieren        AS wahl_panaschieren,".
	     "liste.id                 AS liste_id,".
	     "liste.name_kurz          AS liste_kurz,".
	     "liste.name_lang          AS liste_lang,".
	     "liste.nummer             AS liste_nummer,".
	     "kandidat.typ             AS kandidat_typ,".
	     "kandidat.vorname         AS kandidat_vorname,".
	     "kandidat.nachname        AS kandidat_nachname,".
	     "kandidat.fach            AS kandidat_extra,".
	     "kandidat.listenplatz     AS kandidat_listenplatz ".
	     "FROM wahl, liste, kandidat ".
	     "WHERE wahl.id  = liste.wahl ".
	     "AND   liste.id = kandidat.liste ".
	     "ORDER BY wahl.name_kurz, wahl.id, ".
	     "         liste.nummer, kandidat.listenplatz",
	     do_row ) ;
}

?>
