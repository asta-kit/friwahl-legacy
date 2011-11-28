<?php require("kandidatenliste.php"); 

function yes_handler ( $name, $extra, $platz ) { candidate("Ja","","") ; }
function no_handler ( $name, $extra, $platz ) { candidate("Nein","","") ; }

?>
\documentclass{article}
\usepackage{umodell-zaehlliste}
\usepackage{setspace}

\begin{document}

\begin{center}
    \Large
    Studierendenschaft der Universit�t Karlsruhe (TH)
    \bigskip

    \bfseries
    \Huge
    Wahlen zu den Gremien der Unabh�ngigen Studierendenschaft 2011
    \bigskip

    \LARGE
    Z�hllisten f�r Urne~\hr{5cm}
    \bigskip
    \bigskip

\end{center}

{
\onehalfspacing \raggedright
Liebe Ausz�hlhelfer,\medskip

zun�chst einmal vielen Dank f�r Euer Engagement beim Ausz�hlen der diesj�hrigen Wahl! \medskip

Um euch das Ausz�hlen m�glichst angenehm zu gestalten und doppeltes Ausz�hlen zu vermeiden, hier ein paar Tipps und Regeln: \medskip

\begin{itemize}
 \item Folgendes Vorgehen bei den Wahlen hat sich in den letzten Jahren bew�hrt:
  \begin{enumerate}
   \item Lest die Kommentare vorne im Urnenbuch, damit k�nnt ihr euch ggf. Arbeit sparen. Kontrolliert bitte vor allem, ob dort als durchgestrichen angegebene W�hler (wg. fehlender Wahlberechtigung usw.) in den Listen hinten auch wirklich durchgestrichen sind.
   \item Urne �ffnen und ausleeren, dann pr�fen, ob Stimmzettel auf den Boden gefallen sind
   \item Alle Stimmzettel nach Art sortieren und auffalten
   \item Die Zettel in Haufen von 10-20 St�ck aufteilen
   \item Die Wahlen nacheinander ausz�hlen
   \item Bei den StuPa-Wahlen: die Listenstimmen zuerst ausz�hlen, anschlie�end die Kandidierenden. Bei den Kandidierenden empfiehlt es sich, die Ausz�hlung in mehreren Etappen zu machen, sonst m�sst ihr andauernd umbl�ttern. Die ung�ltigen Stimmzettel k�nnt ihr so im ersten Durchgang direkt loswerden.
  \end{enumerate}
 \item Beim Ausz�hlen:
  \begin{itemize}
   \item einer liest vor, einer kontrolliert das Vorgelesene (beide kontrollieren, ob die Stimmenzahl in Ordnung ist)
   \item Die beiden anderen f�hren unabh�ngig voneinander die Z�hlliste, s.u.
  \end{itemize}
 \item Das F�hren der \textbf{Z�hlliste} wird mit diesen Tipps etwas einfacher:
  \begin{itemize}
   \item Vergleicht regelm��ig eure Zwischenst�nde und fangt danach mit einem senkrechten Strich eine neue Gruppe an
   \item Einer der beiden Z�hler kann nach jedem Namen den aktuellen Z�hlerstand modulo 5 (also den Abstand zum letzten vollen F�nferblock) laut sagen. Damit merkt ihr sofort, wenn ihr auseinanderdriftet, und m�sst nicht am Ende alle Zettel nochmal z�hlen.
  \end{itemize}
 \item Die Unterscheidung zwischen \textbf{ung�ltigen Kandidierendenstimmen und ung�ltigen Zetteln} bei den Fachschafts- und UStA-Referats-Wahlen ist zwar schwierig, aber in einigen Grenzf�llen sinnvoll. Generell gilt: Wenn sich Unregelm��igkeiten erkennbar nur auf einen Kandidaten beziehen (unleserliche Zahl, Durchstreichung des Namens etc.), ist diese Kandiderendenstimme ung�ltig. Bei nicht erkennbarem Kandidatenbezug oder �nderungen am Zettel ist der Zettel als Ganzes ung�ltig. Wenn ihr dazu Fragen habt, wendet euch an den Wahlausschuss.
\end{itemize}

\bigskip

Zuallerletzt w�nschen wir euch noch viel Spa� beim Ausz�hlen! \bigskip

Der Wahlausschuss\smallskip

Julian Gethmann \qquad Mario Prausa \qquad Heiko Rosemann \qquad Andreas Wolf

}

<?php kandidatenliste() ?>

\end{document}
