<?php

/*

 (c) 2003, 2004 Kristof Koehler <Kristof.Koehler@stud.uni-karlsruhe.de>

 Published under GPL

 */

function head ( $title, $file = "" ) {
	if ( $file != "" ) {
		print "\n<NEWFILE $file $title>\n" ;
	}

	$urnen_total = simple_query("SELECT count(*) FROM urne") ;
	$urnen_done  = simple_query("SELECT count(*) FROM urne WHERE status=".
				    $GLOBALS["ok_status"]) ;
	$stimmen_total = simple_query("SELECT sum(stimmen) FROM urne") ;
	$stimmen_done  = simple_query("SELECT sum(stimmen) FROM urne WHERE status=".
				    $GLOBALS["ok_status"]) ;
?>
<html>
  <head><title>Unabhängige Wahlen KIT - <?=$title?></title>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-15">
  <link rel="stylesheet" href="style.css">
  <link rel="stylesheet" href="http://www.usta.de/sites/www.usta.de/themes/usta/font.css">
  </head>
  <body>
     <div id="content">
       <div id="header">
         <h2>Wahlen zum Unabhängigen Modell am Karlsruher Institut für Technologie (KIT)</h2>
         <h1><?=$title?></h1>
         <div class="orange-border">
	   Zwischenstand <?=date("j.n.Y H:i")?>, 
           <?=$urnen_done?> von <?=$urnen_total?> Urnen,
           ca. <?=percent($stimmen_done,$stimmen_total)?>% der Stimmzettel,
           <a href="index.html?cache_dummy=<?=time()?>">&Uuml;bersicht</a>
         </div>
       </div>
<?php
}

function foot () {
?>
    </div>
    <div id="footer">Der Wahlausschuss</div>
  </body>
</html>
<?php
}
?>
