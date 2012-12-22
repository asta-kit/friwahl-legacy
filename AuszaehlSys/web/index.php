<?php

include("dbconfig.php") ;
include("util.php") ;
include("querysys.php") ;
include("headfoot.php") ;

head ( "Wahlergebnisse", "index.html" ) ;
?>
<p>Hier findet Ihr die aktuellen Zwischenst&auml;nde der Wahlen zum
Unabh&auml;ngigen Modell. Wir w&uuml;nschen Euch viel Spa&szlig; beim
Mitfiebern!</p>

<p>Hinweis: "Zwischenstand" ungleich "Hochrechnung". Beachtet also,
welche Urnen schon ausgez&auml;hlt sind. Wenn jemand eine gute
Hochrechnungsformel hat, kann er sich gerne bei uns melden... ;-)</p>

<p>Auch wer sich selbst als Wahlanalytiker bet&auml;tigen will, findet hier
alle Rohdaten, die er braucht. Die Dateien sollten sich in g&auml;ngige
Tabellenkalkulationen und Datenbanken importieren lassen.</p>

<p><?php include ( "index.lst" ) ; ?></p>

Wer faul ist und sich berieseln lassen will oder einen Beamer
aufstellen will: Hier gibt es drei Links, bei denen die Ergebnisseiten 
der Reihe nach automatisch angezeigt werden:<br>
<a href="cycle.php?delay=10&list=all">Alles</a><br>
<a href="cycle.php?delay=10&list=nofs">Alles au&szlig;er Fachschaften</a><br>
<a href="cycle.php?delay=10&list=fs">Nur Fachschaften</a><br>

<?php 
foot() ;
?>
