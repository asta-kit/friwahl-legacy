<?php require("kandidatenliste.php"); 
function yes_handler ( $name, $extra, $platz ) 
{ candidate($name,$extra,$platz) ; }
function no_handler ( $name, $extra, $platz ) {}
?>
\documentclass{article}
\usepackage{umodell-ausschreibung}

\WahlBeginn{<?=simple_query("SELECT value FROM config WHERE tag='from_date'")?>}
\WahlEnde{<?=simple_query("SELECT value FROM config WHERE tag='to_date'")?>}

\begin{document}
<?php kandidatenliste(); ?>
\end{document}
