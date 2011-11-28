<?php

require("../web/dbconfig.php") ;
require("../web/querysys.php") ;
require("../web/util.php") ;

function do_row ( $row ) {
	extract ( $row ) ;
	echo '\brief{'.$wahl.'}{'.$vorname.'}{'.$nachname.'}{'.
		   $strasse.'}{'.$plz.' '.$ort.'}'."\n";
}

?>

\documentclass{wabrief}

\signature{<?=simple_query("SELECT value FROM config WHERE tag='in_charge'")?>\\
           für den Wahlausschuss}

\newcommand{\brief}[5]{
  \begin{letter}{An\\#2 #3\\#4\\[\medskipamount]#5}
    \subject{\bf Unabhängige Wahlen -- #1}
    \opening{Hallo #2,}
    Ich freue mich, Dir mitzuteilen, dass Du gewählt wurdest.
    Ich gratuliere Dir herzlich und wünsche Dir viel Spaß und Erfolg in
    der kommenden Legislaturperiode.

    \closing{Mit freundlichen Grüßen,}
  \end{letter}
}

\begin{document}

<?php
  do_query ( "SELECT wahl.name_lang AS wahl,".
	     "kandidat.vorname, kandidat.nachname, ".
	     "kandidat.strasse, kandidat.plz, kandidat.ort ".
	     "FROM wahl, liste, kandidat ".
	     "WHERE liste.wahl = wahl.id ".
	     "AND kandidat.liste = liste.id ".
	     "AND status=1 ".
	     "ORDER BY kandidat.nachname",
	     do_row ) ;
?>
\end{document}
