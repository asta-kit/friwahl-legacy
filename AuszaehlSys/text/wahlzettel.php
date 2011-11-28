<?php require("kandidatenliste.php"); 

function yes_handler ( $name, $extra, $platz ) { candidate("Ja","","") ; }
function no_handler ( $name, $extra, $platz ) { 
	candidate("Nein","","") ; 
	candidate("Enthaltung","","") ; 
}
?>
\documentclass{ballot}
\usepackage{umodell-ballot}

\ballotrepeattrue

\begin{document}

<?php kandidatenliste() ?>

\end{document}
